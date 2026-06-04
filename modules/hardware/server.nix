{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.hardware.server;
in
  {
    options.local.hardware.server = {
      enable = lib.mkEnableOption "Server memory and storage management (zram, earlyoom, fstrim)";

      earlyoom = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable early OOM killer to prevent system freeze";
        };

        freeMemThreshold = lib.mkOption {
          type = lib.types.int;
          default = 5;
          description = "Minimum available memory percentage before killing processes";
        };

        freeSwapThreshold = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Minimum available swap percentage before killing processes";
        };
      };

      zramSwap = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable zram-based swap";
        };

        algorithm = lib.mkOption {
          type = lib.types.enum ["lzo" "lz4" "zstd" "lz4hc"];
          default = "zstd";
          description = "Compression algorithm for zram";
        };

        memoryPercent = lib.mkOption {
          type = lib.types.int;
          # Servers benefit less from large compressed swap than desktops;
          # 25% leaves more RAM available for service caches.
          default = 25;
          description = "Percentage of RAM to use for zram swap";
        };
      };

      fstrim = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable periodic SSD TRIM for longevity";
        };
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.hardware.server is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      zramSwap = lib.mkIf cfg.zramSwap.enable {
        enable = true;
        inherit (cfg.zramSwap) algorithm memoryPercent;
      };

      services = {
        earlyoom = lib.mkIf cfg.earlyoom.enable {
          enable = true;
          inherit (cfg.earlyoom) freeMemThreshold freeSwapThreshold;
        };

        fstrim.enable = cfg.fstrim.enable;
      };
    };
  }
