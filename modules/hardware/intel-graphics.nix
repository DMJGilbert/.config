{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.hardware.intelGraphics;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.hardware.intelGraphics = {
      enable = lib.mkEnableOption "Intel integrated graphics support";

      vaapi = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable VA-API hardware video acceleration";
        };
      };

      microcode = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Intel CPU microcode updates";
        };
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.hardware.intelGraphics is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      hardware = {
        # Intel CPU microcode
        cpu.intel.updateMicrocode = cfg.microcode.enable;

        # Graphics with VA-API support
        graphics = {
          enable = true;
          extraPackages = lib.mkIf cfg.vaapi.enable (with pkgs; [
            intel-media-driver # VAAPI for Broadwell+ Intel GPUs
            intel-vaapi-driver # VAAPI for older Intel GPUs
            libva-vdpau-driver
            libvdpau-va-gl
          ]);
        };
      };
    };
  }
