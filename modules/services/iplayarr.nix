{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.iplayarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
  mediaGid = toString config.local.services.mediaStorage.gid;
  mediaRoot = config.local.services.mediaStorage.root;
in
  {
    options.local.services.iplayarr = {
      enable = lib.mkEnableOption "iPlayarr BBC iPlayer download bridge for Sonarr/Radarr";

      port = lib.mkOption {
        type = lib.types.port;
        default = 4404;
        description = "Port for the iPlayarr web interface";
      };

      apiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to a file containing API_KEY=<value> to secure the iPlayarr API";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.iplayarr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.local.services.mediaStorage.enable;
          message = "local.services.iplayarr requires local.services.mediaStorage.enable = true.";
        }
      ];

      users.users.iplayarr = {
        isSystemUser = true;
        uid = 569;
        inherit (config.local.services.mediaStorage) group;
        description = "iPlayarr BBC iPlayer download bridge";
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/iplayarr/config 0775 iplayarr ${config.local.services.mediaStorage.group} -"
        "d /var/lib/iplayarr/cache  0775 iplayarr ${config.local.services.mediaStorage.group} -"
        "d /var/lib/iplayarr/logs   0775 iplayarr ${config.local.services.mediaStorage.group} -"
      ];

      virtualisation.oci-containers = {
        backend = "podman";
        containers.iplayarr = {
          image = "nikorag/iplayarr:latest";
          ports = [
            "127.0.0.1:${toString cfg.port}:4404"
          ];
          volumes = [
            "/var/lib/iplayarr/config:/config"
            "/var/lib/iplayarr/cache:/data"
            "/var/lib/iplayarr/logs:/logs"
            "${mediaRoot}/downloads/incomplete:/incomplete"
            "${mediaRoot}/downloads/complete:/complete"
          ];
          environment = {
            TZ = "Europe/London";
            PUID = "569";
            PGID = mediaGid;
            DOWNLOAD_DIR = "/incomplete";
            COMPLETE_DIR = "/complete";
            REFRESH_SCHEDULE = "0 */6 * * *";
          };
          environmentFiles = lib.optional (cfg.apiKeyFile != null) cfg.apiKeyFile;
        };
      };
    };
  }
