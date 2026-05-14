{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./shared.nix
  ];

  # Enable hardware, features, and services via feature-flag modules
  local = {
    hardware = {
      amdGraphics.enable = true;
    };

    profiles.server.enable = true;

    features = {
      ccache.enable = true;
    };

    services = {
      mediaStorage.enable = true;
      jellyfin.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      prowlarr.enable = true;
      jellyseerr.enable = true;
      qbittorrent = {
        enable = true;
        webUIAddress = "0.0.0.0";
      };
      qbittorrentVpn.enable = true;
      homepage.enable = true;
      tdarr.enable = true;
      pinchflat.enable = true;
      homeAssistant = {
        enable = true;
        dashboard.enable = true;
      };
      adguardHome.enable = true;
      nginx = {
        enable = true;
        acme = {
          acceptTerms = true;
          email = "dmjgilbert@gmail.com";
        };
        virtualHosts = {
          "home.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            extraConfig = ''
              proxy_buffering off;
            '';
            proxyPass = "http://127.0.0.1:8123";
            proxyWebsockets = true;
          };
          "adguard.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
          };
          "glances.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:61208";
            proxyWebsockets = true;
          };
          "kuma.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            extraConfig = ''
              proxy_buffering off;
            '';
            proxyPass = "http://127.0.0.1:3001";
            proxyWebsockets = true;
          };
          "sonarr.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:8989";
            proxyWebsockets = true;
          };
          "radarr.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:7878";
            proxyWebsockets = true;
          };
          "prowlarr.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:9696";
            proxyWebsockets = true;
          };
          "jellyseerr.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:5055";
            proxyWebsockets = true;
          };
          "qbittorrent.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            extraConfig = ''
              proxy_buffering off;
              client_max_body_size 100M;
            '';
            proxyPass = "http://10.200.200.2:8081";
            proxyWebsockets = true;
          };
          "tdarr.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:8265";
            proxyWebsockets = true;
          };
          "pinchflat.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:8945";
            proxyWebsockets = true;
          };
          "homepage.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            proxyPass = "http://127.0.0.1:8082";
            proxyWebsockets = true;
          };
          "jellyfin.gilberts.one" = {
            forceSSL = true;
            useACMEHost = "gilberts.one";
            extraConfig = ''
              proxy_buffering off;
              client_max_body_size 20M;
            '';
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
          };
        };
      };
    };
  };

  boot = {
    # Latest kernel for best AMD Ryzen 8845HS + MediaTek MT7922 WiFi support
    kernelPackages = pkgs.linuxPackages_latest;
    # Prevent blank/white screen issues on Radeon 780M iGPU
    kernelParams = ["amdgpu.sg_display=0"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  # Server memory management (replaces laptop module)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  networking = {
    networkmanager.enable = true;
    hostName = "rubecula";

    # Firewall with explicit port allowlist
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP (ACME + nginx redirect)
        443 # HTTPS (nginx)
        8080 # Zigbee2MQTT web frontend
        21064 # HomeKit Accessory Protocol (HAP)
      ];
      allowedUDPPorts = [
        53 # DNS (AdGuard Home)
      ];
    };
  };

  time.timeZone = "Europe/London";

  programs.git.enable = true;

  environment.systemPackages = with pkgs; [vim unzip gcc nmap glances];

  # Glances system monitoring API - HA Glances integration connects to localhost:61208
  # Web UI accessible via Tailscale SSH tunnel: ssh -L 61208:localhost:61208 rubecula
  # Route FlareSolverr's headless browser through the VPN namespace to bypass ISP blocks
  systemd.services.flaresolverr.environment.PROXY_URL = "socks5://10.200.200.2:1080";

  systemd.services.glances = {
    description = "Glances system monitoring API";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      ExecStart = "${pkgs.glances}/bin/glances -w --disable-plugin docker --port 61208 --bind 127.0.0.1";
      Restart = "on-failure";
      User = "nobody";
    };
  };

  services = {
    uptime-kuma = {
      enable = true;
      settings = {
        HOST = "127.0.0.1";
        PORT = "3001";
      };
    };
    openssh.enable = true;
    fstrim.enable = true;
    # Early OOM killer to prevent system freeze under memory pressure
    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
    };
    mosquitto = {
      enable = true;
      listeners = [
        {
          address = "127.0.0.1";
          omitPasswordAuth = true;
          acl = ["topic readwrite #"];
          settings.allow_anonymous = true;
        }
      ];
    };
    flaresolverr = {
      enable = true;
      openFirewall = false;
    };
    zigbee2mqtt = {
      enable = true;
      settings = {
        permit_join = false;
        mqtt.server = "mqtt://localhost";
        serial = {
          port = "/dev/ttyUSB0";
          adapter = "zstack";
        };
        frontend = {
          port = 8080;
          host = "0.0.0.0";
        };
      };
    };
  };

  users.users.zigbee2mqtt.extraGroups = ["dialout"];

  sops = {
    secrets = {
      "NAMECHEAP_API_USER" = {sopsFile = ../secrets/rubecula.yaml;};
      "NAMECHEAP_API_KEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_PRIVATE_KEY" = {
        sopsFile = ../secrets/rubecula.yaml;
        mode = "0400";
        owner = "root";
      };
      "MULLVAD_WG_ADDRESS" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_PEER_PUBKEY" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_PEER_ENDPOINT" = {sopsFile = ../secrets/rubecula.yaml;};
      "MULLVAD_WG_DNS" = {sopsFile = ../secrets/rubecula.yaml;};
    };
    templates = {
      "namecheap-acme-env" = {
        content = ''
          NAMECHEAP_API_USER=${config.sops.placeholder."NAMECHEAP_API_USER"}
          NAMECHEAP_API_KEY=${config.sops.placeholder."NAMECHEAP_API_KEY"}
        '';
        owner = "acme";
      };
      "wg-mullvad.conf" = {
        content = ''
          [Interface]
          PrivateKey = ${config.sops.placeholder."MULLVAD_WG_PRIVATE_KEY"}

          [Peer]
          PublicKey  = ${config.sops.placeholder."MULLVAD_WG_PEER_PUBKEY"}
          Endpoint   = ${config.sops.placeholder."MULLVAD_WG_PEER_ENDPOINT"}
          AllowedIPs = 0.0.0.0/0
          PersistentKeepalive = 25
        '';
        mode = "0400";
        owner = "root";
      };
    };
  };

  security.acme.certs."gilberts.one" = {
    extraDomainNames = ["*.gilberts.one"];
    group = "nginx";
    dnsProvider = "namecheap";
    webroot = lib.mkForce null;
    environmentFile = config.sops.templates."namecheap-acme-env".path;
  };

  system.stateVersion = "26.05";
}
