{
  config,
  lib,
  isLinux,
  ...
}: let
  cfg = config.local.services.matterServer;
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
      # Avahi publishes this host for mDNS discovery of Matter/Thread devices
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

      # mDNS for device discovery
      networking.firewall.allowedUDPPorts = [5353];

      # Thread devices reach the controller from the border router's ULA
      # prefix, on whatever ephemeral port the controller bound. A sleepy
      # device's report can arrive after conntrack has forgotten the
      # controller-initiated flow (30-120 s), so the firewall must accept new
      # inbound traffic from that range. All of fc00::/7 is accepted rather than
      # the current Thread prefix so a re-formed Thread network keeps working;
      # ULA is not routable from the internet.
      # https://community.home-assistant.io/t/ikea-bilresa-switches-huge-delays-in-responding-solved/1004932
      networking.firewall.extraCommands = ''
        ip6tables -A nixos-fw -s fc00::/7 -j nixos-fw-accept
      '';

      # matter.js replaced python-matter-server in HA's own Matter add-on and
      # supports the ICD Check-In protocol that Long Idle Time devices (IKEA
      # BILRESA) rely on. The fabric was imported from python-matter-server
      # (HA vendor 4939, fabric 1) and is stored under server-1-134b; these
      # flags must keep matching it, or matter.js opens a new, empty fabric
      # and every paired device is orphaned.
      services.matterjs-server = {
        enable = true;
        inherit (cfg) port;
        extraArgs = [
          "--vendorid=4939"
          "--fabricid=1"
        ];
      };

      systemd.services.matterjs-server = {
        before = ["home-assistant.service"];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "30s";
        };
      };
    };
  }
