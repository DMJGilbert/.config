# Local backup of service state via restic.
#
# Scope is deliberately state only, never the media library: films and shows
# are re-acquirable, whereas Home Assistant's history, the *arr databases and
# qBittorrent's torrent state are not.
#
# IMPORTANT: a local repository only protects against logical loss — a bad
# deploy, a deleted directory, application corruption. It does NOT survive the
# failure of the disk holding it. rubecula currently has a single disk
# (hardware/rubecula.nix), so point `repository` at a SEPARATE physical device
# (an external USB disk, a second NVMe, a NAS mount) or the backup dies with
# the thing it was protecting. The assertion below catches the obvious cases.
#
# The path list intentionally mirrors modules/services/impermanence.nix — both
# answer the same question ("what is not reproducible from this flake?"), so
# they should be kept in step.
{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.services.backup;
in
  {
    options.local.services.backup = {
      enable = lib.mkEnableOption "Local restic backup of service state";

      repository = lib.mkOption {
        type = lib.types.str;
        example = "/mnt/backup/restic";
        description = ''
          Path to the restic repository. Should live on a different physical
          disk from the data being backed up; see the note at the top of this
          file. A remote URL (`b2:`, `s3:`, `sftp:`) also works if you later
          add an offsite copy.
        '';
      };

      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          File containing the restic repository password. Losing this means
          losing the backups — it is the encryption key, not a login.
        '';
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          EnvironmentFile holding provider credentials. Not needed for a local
          repository; set it only if `repository` points at a remote store.
        '';
      };

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "/var/lib/hass"
          "/var/lib/sonarr"
          "/var/lib/radarr"
          "/var/lib/private/prowlarr"
          "/var/lib/jellyfin"
          "/var/lib/jellyseerr"
          "/var/lib/qBittorrent"
          "/var/lib/pinchflat"
          "/var/lib/dispatcharr"
          "/var/lib/iplayarr"
          # DynamicUser=true services keep state in /var/lib/private/<name>;
          # /var/lib/<name> is only a symlink and would archive nothing.
          "/var/lib/private/technitium-dns-server"
          "/var/lib/private/uptime-kuma"
          "/var/lib/private/matter-server"
          "/var/lib/tailscale"
          "/var/lib/acme"
        ];
        description = "Directories to back up. State only — not the media library.";
      };

      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          # Regenerable caches and transcodes; large and pointless to store.
          "/var/lib/jellyfin/transcodes"
          "/var/lib/jellyfin/cache"
          "**/*.log"
          "**/log/*"
          "**/Cache"
          "**/cache"
        ];
        description = "Exclude patterns passed to restic.";
      };

      acknowledgeSameDisk = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Silence the "repository is on the root filesystem" warning.
          Set this only as a deliberate decision: it records in the config that
          you know this backup does not survive the disk failing, so the
          warning does not become noise you stop reading.
        '';
      };

      timerConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          OnCalendar = "daily";
          # Avoid every timer on the box firing at once.
          RandomizedDelaySec = "30m";
          Persistent = "true";
        };
        description = "systemd timer configuration for the backup job.";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.backup is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          # A repository inside a backed-up path would try to back itself up,
          # growing without bound each run.
          assertion = !(lib.any (p: lib.hasPrefix p cfg.repository) cfg.paths);
          message = ''
            local.services.backup: repository "${cfg.repository}" sits inside one of
            the backed-up paths, so each run would archive the previous run.
            Move it outside `paths`.
          '';
        }
      ];

      # Heuristic only — Nix cannot see the mount table at eval time. Catches
      # the common mistake of putting the repository on the root filesystem,
      # where a disk failure destroys data and backup together.
      warnings =
        lib.optional
        (!cfg.acknowledgeSameDisk
          && lib.hasPrefix "/" cfg.repository
          && lib.any (p: lib.hasPrefix p cfg.repository) ["/var/" "/home/" "/root/" "/tmp/"])
        ''
          local.services.backup: repository "${cfg.repository}" looks like it is on the
          root filesystem. rubecula has a single disk, so this backup would not
          survive that disk failing. Prefer a separate device mounted elsewhere
          (e.g. /mnt/backup).
        '';

      # restic init creates the repository, but not its parent. Without this a
      # local repository under a path that does not exist fails on first run.
      systemd.tmpfiles.rules =
        lib.optional (lib.hasPrefix "/" cfg.repository)
        "d ${cfg.repository} 0700 root root -";

      services.restic.backups.state = {
        inherit (cfg) repository passwordFile environmentFile paths exclude timerConfig;

        initialize = true;

        # Databases copied while being written can restore corrupt. Ask the
        # services to flush first; SQLite users are fine with a plain copy once
        # quiescent, and this keeps the window short.
        backupPrepareCommand = ''
          ${config.systemd.package}/bin/systemctl is-active --quiet home-assistant \
            && ${config.systemd.package}/bin/systemctl stop home-assistant || true
        '';
        backupCleanupCommand = ''
          ${config.systemd.package}/bin/systemctl start home-assistant || true
        '';

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];

        # Verify a subset of actual data, not just metadata. A backup that has
        # never been read is a hypothesis, not a backup.
        checkOpts = ["--read-data-subset=2%"];
      };
    };
  }
