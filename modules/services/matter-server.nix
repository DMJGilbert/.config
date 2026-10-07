{
  config,
  lib,
  pkgs,
  isLinux,
  ...
}: let
  cfg = config.local.services.matterServer;

  # Where python-matter-server kept its fabric. matterjs-server imports
  # chip.json and <compressed-fabric-id>.json from its own storage path, so
  # they are copied across once; this directory is never written to, which
  # keeps it intact for rolling back to python-matter-server.
  legacyStorage = "/var/lib/private/matter-server";
  storage = "/var/lib/private/matterjs-server";

  seedFromLegacy = pkgs.writeShellScript "matterjs-server-seed-legacy" ''
    set -euo pipefail
    if [ -e ${storage}/chip.json ] || [ ! -e ${legacyStorage}/chip.json ]; then
      exit 0
    fi
    echo "Seeding ${storage} from ${legacyStorage}"
    cp -p ${legacyStorage}/chip.json ${legacyStorage}/[0-9]*.json ${storage}/
    chown --reference=${storage} ${storage}/*.json
  '';
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

      # matter.js replaced python-matter-server in HA's own Matter add-on, and
      # registers as an ICD Check-In client so Long Idle Time devices (IKEA
      # BILRESA) keep delivering events. vendorid/fabricid must match the
      # python-matter-server fabric (HA vendor 4939, fabric 1) or the legacy
      # import finds no matching fabric and a new, empty one is created.
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
          # "+" runs the seed as root outside the DynamicUser sandbox, which
          # cannot read the legacy state directory.
          ExecStartPre = ["+${seedFromLegacy}"];
          Restart = "on-failure";
          RestartSec = "30s";
        };
      };
    };
  }
