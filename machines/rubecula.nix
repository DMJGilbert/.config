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
      laptop.enable = true;
      intelGraphics.enable = true;
    };

    features = {
      docker.enable = true;
      ccache.enable = true;
    };

    services = {
      homeAssistant = {
        enable = true;
        dashboard.enable = true;
      };
      tailscale.enable = true;
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

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
  };

  # Machine-specific hardware (Bluetooth)
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
      ];
      allowedUDPPorts = [
        53 # DNS (AdGuard Home)
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  programs.git.enable = true;

  environment.systemPackages = with pkgs; [vim unzip gcc nmap];

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  system.stateVersion = "24.11";
}
