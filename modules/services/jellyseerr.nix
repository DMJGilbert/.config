{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.jellyseerr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.jellyseerr = {
      enable = lib.mkEnableOption "Jellyseerr media request management";

      port = lib.mkOption {
        type = lib.types.port;
        default = 5055;
        description = "Port for the Jellyseerr web interface";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.jellyseerr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.seerr = {
        enable = true;
        openFirewall = false;
        inherit (cfg) port;
      };
    };
  }
