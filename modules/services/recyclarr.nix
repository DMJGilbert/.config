{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.services.recyclarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;

  defaultConfig = pkgs.writeText "recyclarr.yml" ''
    sonarr:
      gilberts-sonarr:
        base_url: http://localhost:8989
        api_key: !secret sonarr_api_key
        include:
          - template: sonarr-quality-definition-series
          - template: sonarr-v4-quality-profile-web-1080p
          - template: sonarr-v4-custom-formats-web-1080p

    radarr:
      gilberts-radarr:
        base_url: http://localhost:7878
        api_key: !secret radarr_api_key
        include:
          - template: radarr-quality-definition-movie
          - template: radarr-quality-profile-hd-bluray-plus-web
          - template: radarr-custom-formats-hd-bluray-plus-web
  '';
in
  {
    options.local.services.recyclarr = {
      enable = lib.mkEnableOption "Recyclarr TRaSH Guides sync for Sonarr/Radarr";

      configFile = lib.mkOption {
        type = lib.types.path;
        default = defaultConfig;
        description = "Path to the recyclarr YAML config file";
      };

      secretsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to a sops-rendered secrets file with sonarr_api_key, radarr_api_key, etc.";
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
      assertions = [
        {
          assertion = cfg.secretsFile != null;
          message = "local.services.recyclarr requires secretsFile to be set (sops template with sonarr_api_key and radarr_api_key).";
        }
      ];

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
          ExecStart = lib.concatStringsSep " " ([
              "${pkgs.recyclarr}/bin/recyclarr"
              "sync"
              "--config"
              (toString cfg.configFile)
            ]
            ++ lib.optional (cfg.secretsFile != null) "--secrets ${cfg.secretsFile}");
          ReadOnlyPaths = [cfg.configFile] ++ lib.optional (cfg.secretsFile != null) cfg.secretsFile;
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
