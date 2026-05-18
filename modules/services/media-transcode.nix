{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.services.mediaTranscode;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.mediaTranscode = {
      enable = lib.mkEnableOption "FFmpeg-based media transcoding via inotify";

      watchDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Directories to watch for new video files to transcode";
      };

      vaapiDevice = lib.mkOption {
        type = lib.types.str;
        default = "/dev/dri/renderD128";
        description = "VAAPI render device path";
      };

      qp = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "H.264 VAAPI quantizer (0-51)";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.mediaTranscode is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable (let
      transcodeScript = pkgs.writeShellApplication {
        name = "media-transcode-file";
        runtimeInputs = [pkgs.ffmpeg];
        text = ''
          # Usage: media-transcode-file <file>
          file="$1"

          # Skip non-video extensions (case-insensitive)
          ext="''${file##*.}"
          case "''${ext,,}" in
            mkv | mp4 | avi | mov | m4v | ts | wmv) ;;
            *) exit 0 ;;
          esac

          # Check if we already encoded this file: FFmpeg writes our encoder tag into
          # the stream metadata, so we can detect our own output and avoid re-encoding.
          encoder=$(ffprobe -v error -select_streams v:0 \
            -show_entries stream_tags=encoder \
            -of default=noprint_wrappers=1:nokey=1 "$file")
          already_ours=false
          [[ "$encoder" == *"h264_vaapi"* ]] && already_ours=true

          # Probe audio streams
          audio_count=$(ffprobe -v error -select_streams a \
            -show_entries stream=index \
            -of csv=p=0 "$file" | wc -l)

          # Count English-tagged audio streams (grep -c exits 1 on no match, || handles it)
          eng_count=0
          if [[ "$audio_count" -gt 1 ]]; then
            eng_count=$(ffprobe -v error -select_streams a \
              -show_entries stream_tags=language \
              -of default=noprint_wrappers=1:nokey=1 "$file" \
              | grep -c "^eng$") || eng_count=0
          fi

          # Audio needs filtering when: >1 streams, at least one is eng, at least one is not
          needs_audio_filter=false
          if [[ "$audio_count" -gt 1 && "$eng_count" -gt 0 && "$eng_count" -lt "$audio_count" ]]; then
            needs_audio_filter=true
          fi

          # Skip only if we encoded this file ourselves AND audio is already clean
          if $already_ours && ! $needs_audio_filter; then
            exit 0
          fi

          # Build audio map: keep only English when filtering, else keep all
          audio_args=()
          if $needs_audio_filter; then
            audio_args+=(-map "0:a:m:language:eng")
          else
            audio_args+=(-map "0:a?")
          fi

          # Temp file alongside original; cleaned up on any exit
          dir="''${file%/*}"
          base="''${file##*/}"
          tmp="$dir/.transcode-tmp-$$-$base"
          trap 'rm -f "$tmp"' EXIT

          echo "Transcoding: $file"
          ffmpeg -y \
            -hwaccel vaapi \
            -hwaccel_output_format vaapi \
            -hwaccel_device "${cfg.vaapiDevice}" \
            -i "$file" \
            -map 0:v:0 \
            "''${audio_args[@]}" \
            -map "0:s?" \
            -vf "format=nv12|vaapi,setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709,hwupload" \
            -c:v h264_vaapi \
            -qp ${toString cfg.qp} \
            -c:a copy \
            -c:s copy \
            "$tmp"

          mv "$tmp" "$file"
          echo "Done: $file"
        '';
      };

      watchScript = pkgs.writeShellApplication {
        name = "media-transcode-watch";
        runtimeInputs = [pkgs.inotify-tools transcodeScript];
        text = ''
          echo "Watching directories: ${lib.escapeShellArgs cfg.watchDirs}"
          inotifywait -m -r \
            -e close_write \
            -e moved_to \
            --format '%w%f' \
            ${lib.escapeShellArgs cfg.watchDirs} \
            | while IFS= read -r path; do
                media-transcode-file "$path"
              done
        '';
      };

      scanScript = pkgs.writeShellApplication {
        name = "media-transcode-scan";
        runtimeInputs = [pkgs.findutils transcodeScript];
        text = ''
          echo "Scanning directories: ${lib.escapeShellArgs cfg.watchDirs}"
          while IFS= read -r -d "" file; do
            media-transcode-file "$file"
          done < <(find ${lib.escapeShellArgs cfg.watchDirs} \
            -type f \
            \( \
              -iname "*.mkv" \
              -o -iname "*.mp4" \
              -o -iname "*.avi" \
              -o -iname "*.mov" \
              -o -iname "*.m4v" \
              -o -iname "*.ts" \
              -o -iname "*.wmv" \
            \) \
            -print0)
        '';
      };
    in {
      assertions = [
        {
          assertion = config.local.services.mediaStorage.enable;
          message = "local.services.mediaTranscode requires local.services.mediaStorage.enable = true.";
        }
        {
          assertion = cfg.watchDirs != [];
          message = "local.services.mediaTranscode.watchDirs must not be empty.";
        }
      ];

      users.users.media-transcode = {
        isSystemUser = true;
        group = config.local.services.mediaStorage.group;
        extraGroups = ["render" "video"];
        description = "media-transcode service user";
      };

      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="renderD*", MODE="0666"
      '';

      systemd.services.media-transcode = {
        description = "Watch media dirs and transcode new video files to H.264";
        wantedBy = ["multi-user.target"];
        after = ["local-fs.target"];
        serviceConfig = {
          ExecStart = "${watchScript}/bin/media-transcode-watch";
          Restart = "on-failure";
          RestartSec = "10s";
          User = "media-transcode";
        };
      };

      systemd.services.media-transcode-scan = {
        description = "Scan and transcode all video files in media directories";
        serviceConfig = {
          ExecStart = "${scanScript}/bin/media-transcode-scan";
          Type = "oneshot";
          User = "media-transcode";
        };
      };
    });
  }
