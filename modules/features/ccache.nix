{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.features.ccache;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.features.ccache = {
      enable = lib.mkEnableOption "ccache for faster rebuilds";

      sandboxSupport = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Add ccache cache directory to nix sandbox paths";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.features.ccache is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      programs.ccache.enable = true;

      nix.settings.extra-sandbox-paths = lib.mkIf cfg.sandboxSupport [
        config.programs.ccache.cacheDir
      ];
    };
  }
