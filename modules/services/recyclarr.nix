{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.services.recyclarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.recyclarr = {
      enable = lib.mkEnableOption "Recyclarr TRaSH Guides sync for Sonarr/Radarr";

      configFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to the recyclarr YAML config file (must contain literal API keys — use a sops template)";
      };

      onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "04:00";
        description = "Systemd timer schedule for recyclarr sync";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.recyclarr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      users.users.recyclarr = {
        isSystemUser = true;
        uid = 567;
        group = "recyclarr";
        description = "Recyclarr TRaSH Guides sync service";
      };
      users.groups.recyclarr = {};

      systemd.services.recyclarr = {
        description = "Recyclarr TRaSH Guides sync";
        serviceConfig = {
          Type = "oneshot";
          User = "recyclarr";
          # recyclarr writes migration markers and cache under $HOME/.config;
          # system users default to /var/empty (read-only), so redirect home here
          StateDirectory = "recyclarr";
          Environment = ["HOME=/var/lib/recyclarr"];
          ExecStart = "${pkgs.recyclarr}/bin/recyclarr sync --config ${toString cfg.configFile}";
          ReadOnlyPaths = [cfg.configFile];
        };
      };

      systemd.timers.recyclarr = {
        description = "Recyclarr sync timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = cfg.onCalendar;
          Persistent = true;
          RandomizedDelaySec = "5m";
        };
      };
    };
  }
