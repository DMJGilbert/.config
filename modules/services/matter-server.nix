{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.matterServer;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.matterServer = {
      enable = lib.mkEnableOption "Matter server for Thread/Matter smart home devices";

      port = lib.mkOption {
        type = lib.types.port;
        default = 5580;
        description = "Port for the Matter server to listen on";
      };
    };

    # Warn if enabled on unsupported platform
    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.matterServer is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.matter-server = {
        enable = true;
        inherit (cfg) port;
      };
    };
  }
