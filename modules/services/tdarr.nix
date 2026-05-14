{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.tdarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
  mediaGid = toString config.local.services.mediaStorage.gid;
in
  {
    options.local.services.tdarr = {
      enable = lib.mkEnableOption "Tdarr automated media transcoding pipeline";

      webUIPort = lib.mkOption {
        type = lib.types.port;
        default = 8265;
        description = "Port for the Tdarr web UI";
      };

      serverPort = lib.mkOption {
        type = lib.types.port;
        default = 8266;
        description = "Port for the Tdarr server (node communication)";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.tdarr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.local.services.mediaStorage.enable;
          message = "local.services.tdarr requires local.services.mediaStorage.enable = true.";
        }
      ];

      users.users.tdarr = {
        isSystemUser = true;
        uid = 568;
        inherit (config.local.services.mediaStorage) group;
        description = "Tdarr transcoding service user";
      };

      # Make DRM render nodes accessible inside the container for VAAPI
      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="renderD*", MODE="0666"
      '';

      systemd.tmpfiles.rules = [
        "d /var/lib/tdarr/server       0775 tdarr ${config.local.services.mediaStorage.group} -"
        "d /var/lib/tdarr/configs      0775 tdarr ${config.local.services.mediaStorage.group} -"
        "d /var/lib/tdarr/logs         0775 tdarr ${config.local.services.mediaStorage.group} -"
        "d /var/lib/tdarr/transcode-cache 0775 tdarr ${config.local.services.mediaStorage.group} -"
      ];

      virtualisation.oci-containers = {
        backend = "podman";
        containers.tdarr = {
          image = "ghcr.io/haveagitgat/tdarr:latest";
          ports = [
            "127.0.0.1:${toString cfg.webUIPort}:8265"
            "127.0.0.1:${toString cfg.serverPort}:8266"
          ];
          volumes = [
            "/var/lib/tdarr/server:/app/server"
            "/var/lib/tdarr/configs:/app/configs"
            "/var/lib/tdarr/logs:/app/logs"
            "/var/lib/media:/media"
            "/var/lib/tdarr/transcode-cache:/temp"
          ];
          environment = {
            TZ = "Europe/London";
            PUID = "568";
            PGID = mediaGid;
            UMASK_SET = "002";
            serverIP = "0.0.0.0";
            serverPort = toString cfg.serverPort;
            webUIPort = toString cfg.webUIPort;
            internalNode = "true";
            inContainer = "true";
            nodeName = "rubecula";
          };
          extraOptions = [
            "--device=/dev/dri:/dev/dri"
          ];
        };
      };
    };
  }
