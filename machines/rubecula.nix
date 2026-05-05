{
  pkgs,
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
        virtualHosts."home.gilberts.one" = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            proxy_buffering off;
          '';
          proxyPass = "http://127.0.0.1:8123";
          proxyWebsockets = true;
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

  environment.systemPackages = with pkgs; [vim unzip gcc nmap];

  services = {
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
          acl = ["pattern readwrite #"];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };
    zigbee2mqtt = {
      enable = true;
      settings = {
        homeassistant = true;
        permit_join = false;
        mqtt.server = "mqtt://localhost";
        serial = {
          port = "/dev/zigbee";
          adapter = "ezsp";
        };
        frontend.port = 8080;
      };
    };
  };

  users.users.zigbee2mqtt.extraGroups = ["dialout"];

  system.stateVersion = "26.05";
}
