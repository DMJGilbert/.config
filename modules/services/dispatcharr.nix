{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.services.dispatcharr;
in
  {
    options.local.services.dispatcharr = {
      enable = lib.mkEnableOption "Dispatcharr IPTV manager and HDHomeRun emulator for Jellyfin";

      port = lib.mkOption {
        type = lib.types.port;
        default = 9191;
        description = "Port for the Dispatcharr web interface and HDHomeRun emulation endpoint";
      };

      vaapi = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Pass /dev/dri/renderD128 into the container for VAAPI hardware transcoding";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.dispatcharr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/dispatcharr/data 0755 root root -"
      ];

      virtualisation.oci-containers.containers.dispatcharr = {
        image = "ghcr.io/dispatcharr/dispatcharr:latest";
        ports = [
          "127.0.0.1:${toString cfg.port}:9191"
        ];
        volumes = [
          "/var/lib/dispatcharr/data:/data"
        ];
        environment = {
          TZ = "Europe/London";
          DISPATCHARR_ENV = "aio";
        };
        extraOptions =
          lib.optional cfg.vaapi "--device=/dev/dri/renderD128:/dev/dri/renderD128";
      };
    };
  }
