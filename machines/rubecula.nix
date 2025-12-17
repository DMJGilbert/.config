{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./shared.nix
  ];

  # Enable hardware and services via feature-flag modules
  local.hardware = {
    laptop.enable = true;
    intelGraphics.enable = true;
  };

  local.services = {
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

  nix = {
    settings = {
      # Enable ccache in sandbox builds
      extra-sandbox-paths = [config.programs.ccache.cacheDir];
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
    # networking.hostName = "nixos"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    hostName = "rubecula";

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  programs = {
    git.enable = true;
    # Enable ccache for faster rebuilds
    ccache.enable = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  environment.systemPackages = with pkgs; [vim unzip gcc];

  virtualisation.docker.enable = true;

  # ACME is now configured via local.services.nginx.acme

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Laptop power, thermal, and memory management now via local.hardware.laptop
    # Tailscale, AdGuard Home, and nginx now via local.services.*

    # ollama = {
    #   enable = true;
    #   openFirewall = true;
    #   host = "0.0.0.0";
    #   port = 6667;
    #   acceleration = "cuda";
    #   loadModels = ["devstral"];
    # };

    # open-webui = {
    #   enable = true;
    #   host = "0.0.0.0";
    #   port = 6666;
    #   openFirewall = true;
    #   environment = {
    #     ANONYMIZED_TELEMETRY = "False";
    #     DO_NOT_TRACK = "True";
    #     SCARF_NO_ANALYTICS = "True";
    #     OLLAMA_API_BASE_URL = "http://127.0.0.1:6667";
    #     WEBUI_AUTH = "False";
    #   };
    # };
  };
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
