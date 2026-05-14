{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.services.qbittorrentVpn;
  isLinux = builtins.match ".*-linux" currentSystem != null;
in
  {
    options.local.services.qbittorrentVpn = {
      enable = lib.mkEnableOption "Mullvad WireGuard VPN kill-switch for qBittorrent via network namespace";

      namespace = lib.mkOption {
        type = lib.types.str;
        default = "wg";
        description = "Name of the network namespace to create";
      };

      vethHostIp = lib.mkOption {
        type = lib.types.str;
        default = "10.200.200.1";
        description = "IP address of the veth interface on the host side";
      };

      vethNsIp = lib.mkOption {
        type = lib.types.str;
        default = "10.200.200.2";
        description = "IP address of the veth interface inside the namespace (nginx proxies to this)";
      };

      vethCidr = lib.mkOption {
        type = lib.types.str;
        default = "30";
        description = "CIDR prefix length for the veth pair subnet";
      };

      wgInterface = lib.mkOption {
        type = lib.types.str;
        default = "wg-mullvad";
        description = "Name of the WireGuard interface";
      };

      wgConfigPath = lib.mkOption {
        type = lib.types.str;
        default = config.sops.templates."wg-mullvad.conf".path;
        description = "Path to the rendered WireGuard config file (from sops template)";
      };

      wgAddressPath = lib.mkOption {
        type = lib.types.str;
        default = config.sops.secrets."MULLVAD_WG_ADDRESS".path;
        description = "Path to the sops secret containing the WireGuard interface address (e.g. 10.x.x.x/32)";
      };

      dns = lib.mkOption {
        type = lib.types.str;
        default = "10.64.0.1";
        description = "DNS server to use inside the namespace (Mullvad's DNS)";
      };

      enableProxy = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run a SOCKS5 proxy (microsocks) inside the namespace on proxyPort, reachable at vethNsIp:proxyPort from the host";
      };

      proxyPort = lib.mkOption {
        type = lib.types.port;
        default = 1080;
        description = "Port for the in-namespace SOCKS5 proxy";
      };
    };

    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.qbittorrentVpn is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.local.services.qbittorrent.enable;
          message = "local.services.qbittorrentVpn requires local.services.qbittorrent.enable = true.";
        }
        {
          assertion =
            config.local.services.qbittorrent.webUIAddress
            == "0.0.0.0"
            || config.local.services.qbittorrent.webUIAddress == cfg.vethNsIp;
          message = ''
            qBittorrent WebUI must bind to 0.0.0.0 (or ${cfg.vethNsIp}) when running inside
            the network namespace — 127.0.0.1 inside the netns is unreachable from the host.
            Set local.services.qbittorrent.webUIAddress = "0.0.0.0" in machines/rubecula.nix.
          '';
        }
      ];

      # Per-namespace resolv.conf — processes in the netns read this automatically
      environment.etc."netns/${cfg.namespace}/resolv.conf".text = "nameserver ${cfg.dns}\n";

      systemd.services = {
        # Persistent network namespace
        "netns-${cfg.namespace}" = {
          description = "Persistent network namespace ${cfg.namespace}";
          wantedBy = ["multi-user.target"];
          before = ["wg-netns.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            PrivateNetwork = false;
            ExecStart = "${pkgs.iproute2}/bin/ip netns add ${cfg.namespace}";
            ExecStop = "${pkgs.iproute2}/bin/ip netns delete ${cfg.namespace}";
          };
        };

        # WireGuard tunnel inside the namespace + veth bridge back to host
        wg-netns = {
          description = "Mullvad WireGuard tunnel in netns ${cfg.namespace}";
          wantedBy = ["multi-user.target"];
          after = ["netns-${cfg.namespace}.service" "network-online.target"];
          requires = ["netns-${cfg.namespace}.service"];
          wants = ["network-online.target"];
          path = [pkgs.iproute2 pkgs.wireguard-tools];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            # Leading dash ignores errors — makes restarts idempotent
            ExecStartPre = "-${pkgs.iproute2}/bin/ip link delete ${cfg.wgInterface}";
          };
          script = ''
            set -euo pipefail

            # 1. Create WireGuard interface in root netns
            ip link add ${cfg.wgInterface} type wireguard

            # 2. Apply Mullvad config (must happen in root netns where /run/secrets lives)
            wg setconf ${cfg.wgInterface} ${cfg.wgConfigPath}

            # 3. Move the interface into the namespace
            ip link set ${cfg.wgInterface} netns ${cfg.namespace}

            # 4. Inside the netns: assign address, bring up, set default route
            ADDR=$(cat ${cfg.wgAddressPath})
            ip -n ${cfg.namespace} address add "$ADDR" dev ${cfg.wgInterface}
            ip -n ${cfg.namespace} link set ${cfg.wgInterface} up
            ip -n ${cfg.namespace} link set lo up
            ip -n ${cfg.namespace} route add default dev ${cfg.wgInterface}

            # 5. veth pair so host nginx can reach the qBittorrent WebUI
            ip link add veth-wg-host type veth peer name veth-wg-ns
            ip link set veth-wg-ns netns ${cfg.namespace}
            ip address add ${cfg.vethHostIp}/${cfg.vethCidr} dev veth-wg-host
            ip link set veth-wg-host up
            ip -n ${cfg.namespace} address add ${cfg.vethNsIp}/${cfg.vethCidr} dev veth-wg-ns
            ip -n ${cfg.namespace} link set veth-wg-ns up
          '';
          preStop = ''
            ${pkgs.iproute2}/bin/ip link delete veth-wg-host || true
            ip -n ${cfg.namespace} link delete ${cfg.wgInterface} || true
          '';
        };

        # SOCKS5 proxy inside the namespace — lets host services (Prowlarr)
        # route requests through the VPN without entering the namespace
        microsocks = lib.mkIf cfg.enableProxy {
          description = "SOCKS5 proxy inside VPN namespace for host services";
          wantedBy = ["multi-user.target"];
          after = ["wg-netns.service"];
          bindsTo = ["wg-netns.service"];
          serviceConfig = {
            NetworkNamespacePath = "/var/run/netns/${cfg.namespace}";
            ExecStart = "${pkgs.microsocks}/bin/microsocks -p ${toString cfg.proxyPort}";
            Restart = "on-failure";
            RestartSec = "5s";
            DynamicUser = true;
          };
        };

        # Move qBittorrent into the namespace — bindsTo is the kill-switch:
        # if wg-netns stops, systemd stops qBittorrent immediately
        qbittorrent = {
          bindsTo = ["wg-netns.service"];
          after = ["wg-netns.service"];
          requires = ["wg-netns.service"];
          serviceConfig = {
            NetworkNamespacePath = "/var/run/netns/${cfg.namespace}";
            Restart = lib.mkForce "on-failure";
            RestartSec = lib.mkForce "5s";
            UMask = "0002";
          };
        };
      };
    };
  }
