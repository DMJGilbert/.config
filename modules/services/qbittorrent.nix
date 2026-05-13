{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.qbittorrent;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.qbittorrent = {
      enable = lib.mkEnableOption "qBittorrent torrent client";

      webUIPort = lib.mkOption {
        type = lib.types.port;
        default = 8081;
        description = "Port for the qBittorrent web interface (8080 is taken by Zigbee2MQTT)";
      };

      webUIAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address for the qBittorrent web interface to bind to. Set to 0.0.0.0 when running inside a network namespace.";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.qbittorrent is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      services.qbittorrent = {
        enable = true;
        openFirewall = false;
        webuiPort = cfg.webUIPort;
        serverConfig.Preferences.WebUI.Address = cfg.webUIAddress;
      };

      users.users.qbittorrent.extraGroups =
        lib.optional config.local.services.mediaStorage.enable
        config.local.services.mediaStorage.group;
    };
  }
