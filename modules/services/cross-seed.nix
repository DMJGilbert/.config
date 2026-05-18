{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.crossSeed;
  isLinux = builtins.match ".*-linux" currentSystem != null;
  mediaGid = toString config.local.services.mediaStorage.gid;
  mediaRoot = config.local.services.mediaStorage.root;
in
  {
    options.local.services.crossSeed = {
      enable = lib.mkEnableOption "cross-seed automatic cross-seeding for qBittorrent";

      port = lib.mkOption {
        type = lib.types.port;
        default = 2468;
        description = "Port for the cross-seed REST API";
      };

      qbittorrentUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://10.200.200.2:8081";
        description = "URL for the qBittorrent WebUI (must be reachable from host)";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.crossSeed is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.local.services.mediaStorage.enable;
          message = "local.services.crossSeed requires local.services.mediaStorage.enable = true.";
        }
        {
          assertion = config.local.services.qbittorrent.enable;
          message = "local.services.crossSeed requires local.services.qbittorrent.enable = true.";
        }
      ];

      users.users.cross-seed = {
        isSystemUser = true;
        uid = 566;
        inherit (config.local.services.mediaStorage) group;
        description = "cross-seed automatic cross-seeding";
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/cross-seed/config    0775 cross-seed ${config.local.services.mediaStorage.group} -"
        "d /var/lib/cross-seed/cross-seeds 0775 cross-seed ${config.local.services.mediaStorage.group} -"
      ];

      virtualisation.oci-containers = {
        backend = "podman";
        containers.cross-seed = {
          image = "ghcr.io/cross-seed/cross-seed:latest";
          # Host networking lets cross-seed reach qBittorrent at 10.200.200.2:8081
          # which falls within the WebUI subnet whitelist (10.200.200.0/30)
          extraOptions = ["--network=host"];
          volumes = [
            "/var/lib/cross-seed/config:/config"
            "/var/lib/cross-seed/cross-seeds:/cross-seeds"
            # qBittorrent torrent files (host filesystem, unaffected by netns)
            "/var/lib/qbittorrent/.local/share/qBittorrent/BT_backup:/qbit-data:ro"
            "${mediaRoot}/downloads/complete:/media/complete"
            "${mediaRoot}/tv:/media/tv"
            "${mediaRoot}/movies:/media/movies"
          ];
          environment = {
            TZ = "Europe/London";
            PUID = "566";
            PGID = mediaGid;
          };
          cmd = ["daemon"];
        };
      };
    };
  }
