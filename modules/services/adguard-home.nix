{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.adguardHome;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.adguardHome = {
      enable = lib.mkEnableOption "AdGuard Home DNS ad-blocker";

      mutableSettings = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Allow settings to be modified through the web UI";
      };
    };

    # Warn if enabled on unsupported platform
    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.adguardHome is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.adguardhome = {
        enable = true;
        inherit (cfg) mutableSettings;
      };
    };
  }
