{
  config,
  lib,
  currentSystem,
  ...
}: let
  cfg = config.local.services.matterServer;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.matterServer = {
      enable = lib.mkEnableOption "Matter server for Thread/Matter smart home devices";

      port = lib.mkOption {
        type = lib.types.port;
        default = 5580;
        description = "Port for the Matter server to listen on";
      };
    };

    # Warn if enabled on unsupported platform
    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.matterServer is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      # Avahi is required for mDNS discovery of Matter/Thread devices
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

      # Open mDNS port for device discovery
      networking.firewall.allowedUDPPorts = [5353];

      services.matter-server = {
        enable = true;
        inherit (cfg) port;
      };

      # Auto-restart on failure and ensure Avahi starts first
      systemd.services.matter-server = {
        after = ["avahi-daemon.service"];
        requires = ["avahi-daemon.service"];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "30s";
        };
      };
    };
  }
