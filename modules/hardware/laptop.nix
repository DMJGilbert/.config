{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.hardware.laptop;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.hardware.laptop = {
      enable = lib.mkEnableOption "Laptop power and thermal management";

      powerManagement = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable power management";
        };

        powertop = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable powertop auto-tuning";
        };
      };

      autoCpufreq = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable auto-cpufreq for automatic CPU frequency scaling";
        };
      };

      thermal = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable thermal management with thermald";
        };
      };

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
          description = "Enable zram-based swap for better performance";
        };

        algorithm = lib.mkOption {
          type = lib.types.enum ["lzo" "lz4" "zstd" "lz4hc"];
          default = "zstd";
          description = "Compression algorithm for zram";
        };

        memoryPercent = lib.mkOption {
          type = lib.types.int;
          default = 50;
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

      lidSwitch = lib.mkOption {
        type = lib.types.enum ["ignore" "suspend" "hibernate" "poweroff"];
        default = "ignore";
        description = "Action to take when laptop lid is closed";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.hardware.laptop is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      # Power Management
      powerManagement = {
        inherit (cfg.powerManagement) enable;
        powertop.enable = cfg.powerManagement.powertop;
      };

      # Zram swap
      zramSwap = lib.mkIf cfg.zramSwap.enable {
        enable = true;
        inherit (cfg.zramSwap) algorithm memoryPercent;
      };

      services = {
        # Auto CPU frequency scaling
        auto-cpufreq = lib.mkIf cfg.autoCpufreq.enable {
          enable = true;
          settings = {
            charger = {
              governor = "performance";
              turbo = "auto";
            };
            battery = {
              governor = "powersave";
              turbo = "auto";
            };
          };
        };

        # Thermal Management
        thermald.enable = cfg.thermal.enable;

        # Early OOM killer
        earlyoom = lib.mkIf cfg.earlyoom.enable {
          enable = true;
          inherit (cfg.earlyoom) freeMemThreshold freeSwapThreshold;
        };

        # SSD TRIM
        fstrim.enable = cfg.fstrim.enable;

        # Lid switch handling
        logind.settings.Login.HandleLidSwitch = cfg.lidSwitch;
      };
    };
  }
