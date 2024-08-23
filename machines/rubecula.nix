{
  pkgs,
  modulesPath,
  ...
}: let
  theme = pkgs.hass-catppuccin;
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./../modules/home-assistant/automations.nix
    ./../modules/home-assistant/components.nix
    ./shared.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostName = "rubecula";

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  programs.git.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  environment.systemPackages = with pkgs; [vim unzip gcc hass-catppuccin];

  services.tailscale.enable = true;

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "dmjgilbert@gmail.com";

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."home.gilberts.one" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };
    };
  };

  services.home-assistant = {
    enable = true;
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-graph-card
      multiple-entity-row
      decluttering-card
      button-card
      lg-webos-remote-control
      light-entity-card
      mushroom
    ];

    config = {
      default_config = {};
      logger = {
        logs = {
        };
      };
      homeassistant = {
        name = "Home";
        country = "GB";
        unit_system = "metric";
        time_zone = "Europe/London";
        internal_url = "https://home.gilberts.one";
        external_url = "https://home.gilberts.one";
        allowlist_external_dirs = ["/etc"];
      };
      http = {
        server_host = "0.0.0.0";
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1"];
      };
      mobile_app = {};
      frontend.themes = "!include ${theme}/${theme.pname}.yaml";
      history = {};
      config = {};
      system_health = {};
      lovelace = {
        mode = "yaml";
        resources = [
          {
            url = "/local/nixos-lovelace-modules/mushroom.js";
            type = "module";
          }
          {
            url = "/local/nixos-lovelace-modules/multiple-entity-row.js";
            type = "module";
          }
          {
            url = "/local/nixos-lovelace-modules/decluttering-card.js";
            type = "module";
          }
          {
            url = "/local/nixos-lovelace-modules/button-card.js";
            type = "module";
          }
          {
            url = "/local/nixos-lovelace-modules/light-entity-card.js";
            type = "module";
          }
          {
            url = "/local/nixos-lovelace-modules/mini-graph-card-bundle.js";
            type = "module";
          }
          {
            url = "/local/nixos-lovelace-modules/lg-remote-control.js";
            type = "module";
          }
        ];
      };
      ffmpeg = {};
      group = {
        robynne_lights = {
          name = "Robynne Lights";
          entities = [
            "light.robynne_light"
            "light.aarlo_nursery"
            "switch.fairy_lights_switch"
          ];
        };
      };
      scene = [];
    };
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
