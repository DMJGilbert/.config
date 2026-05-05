{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.hardware.amdGraphics;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.hardware.amdGraphics = {
      enable = lib.mkEnableOption "AMD integrated graphics support";

      initrd = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Load amdgpu kernel module during initrd for early KMS";
        };
      };

      vaapi = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable VA-API hardware video acceleration";
        };
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.hardware.amdGraphics is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      hardware = {
        amdgpu.initrd.enable = cfg.initrd.enable;

        graphics = lib.mkIf cfg.vaapi.enable {
          enable = true;
        };
      };
    };
  }
