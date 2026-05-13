{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.prowlarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.prowlarr = {
      enable = lib.mkEnableOption "Prowlarr indexer aggregator";
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.prowlarr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.prowlarr = {
        enable = true;
        openFirewall = false;
      };
    };
  }
