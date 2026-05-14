{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.tdarr;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.tdarr = {
      enable = lib.mkEnableOption "Tdarr automated media transcoding pipeline";
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.tdarr is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.local.services.mediaStorage.enable;
          message = "local.services.tdarr requires local.services.mediaStorage.enable = true.";
        }
      ];

      services.tdarr = {
        enable = true;
        inherit (config.local.services.mediaStorage) group;
        server = {
          serverIP = "127.0.0.1";
          serverPort = 8266;
          webUIPort = 8265;
        };
        nodes.main = {
          workers = {
            transcodeGPU = 1;
            transcodeCPU = 0;
            healthcheckGPU = 0;
            healthcheckCPU = 1;
          };
        };
      };

      # VAAPI access for hardware transcoding
      users.users.tdarr.extraGroups = ["render" "video"];

      # Allow server and node to read/write the media library
      systemd.services.tdarr-server.serviceConfig.ReadWritePaths = [
        config.local.services.mediaStorage.root
      ];
      systemd.services.tdarr-node-main.serviceConfig.ReadWritePaths = [
        config.local.services.mediaStorage.root
      ];
    };
  }
