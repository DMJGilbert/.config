{
  pkgs,
  modulesPath,
  ...
}: let
  theme = pkgs.hass-catppuccin;
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
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

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."home.gilberts.one" = {
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
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
      "light"
      "blueprint"
      "bluetooth"
      "automation"
      "tplink"
      "hue"
      "apple_tv"
      "itunes"
      "weatherkit"
      "webostv"
      "homekit"
      "homekit_controller"
      "zeroconf"
      "zha"
    ];
    customComponents = [
      (pkgs.buildHomeAssistantComponent rec {
        owner = "amosyuen";
        domain = "tplink_deco";
        version = "3.6.2";
        src = pkgs.fetchFromGitHub {
          owner = "amosyuen";
          repo = "ha-tplink-deco";
          rev = "v${version}";
          sha256 = "sha256-RYj06jkkauzZsVQtDZ9VBWheRU25qwC7NaSzgOlwppA=";
        };
        propagatedBuildInputs = [
          pkgs.python312Packages.pycryptodome
        ];
      })
      (pkgs.buildHomeAssistantComponent rec {
        owner = "libdyson-wg";
        domain = "dyson_local";
        version = "1.3.11";
        src = pkgs.fetchFromGitHub {
          owner = "libdyson-wg";
          repo = "ha-dyson";
          rev = "v${version}";
          sha256 = "sha256-NWHMc70TA2QYmMHf8skY6aIkRs4iP+1NDURQDhi2yGc=";
        };
        propagatedBuildInputs = [
          pkgs.python312Packages.pycryptodome
        ];
      })
      (pkgs.buildHomeAssistantComponent rec {
        owner = "twrecked";
        domain = "aarlo";
        version = "0.8.1.4";
        src = pkgs.fetchFromGitHub {
          owner = "twrecked";
          repo = "hass-aarlo";
          rev = "v${version}";
          sha256 = "sha256-IkHtTnDpAJhuRA+IHzqCgRcferKAmQJLKWHq6+r3SrE=";
        };
        propagatedBuildInputs = [
          pkgs.python312Packages.unidecode
          (
            pkgs.python3.pkgs.buildPythonPackage rec {
              pname = "pyaarlo";
              version = "0.8.0.7";
              pyproject = true;
              src = pkgs.fetchPypi {
                inherit pname version;
                hash = "sha256-mhlSdFNznDj9WqDr6o71f0EBUThZUSXsJH259mSBzrM=";
              };
              propagatedBuildInputs = with pkgs.python3Packages; [
                setuptools
                requests
                click
                pycryptodome
                unidecode
                cloudscraper
                paho-mqtt
                cryptography
              ];
            }
          )
        ];
      })
    ];

    config = {
      default_config = {};
      logger = {
        logs = {
          "custom_components.tplink_deco" = "debug";
        };
      };
      homeassistant = {
        name = "Home";
        country = "GB";
        unit_system = "metric";
        time_zone = "Europe/London";
        internal_url = "http://home.gilberts.one";
        external_url = "http://192.168.68.101";
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
      automation = [
        {
          alias = "Bathroom lights";
          description = "";
          use_blueprint = {
            path = "homeassistant/motion_light.yaml";
            input = {
              motion_entity = "binary_sensor.motion_sensor_motion";
              light_target = {
                device_id = [
                  "32ef84d09639b9658e63b093154c3417"
                  "c45cc91ddf472466af9ab2293ef3963d"
                ];
              };
              no_motion_wait = 30;
            };
          };
        }
      ];
      scene = [
        {
          name = "Bathtime";
          entities = {
            "light.bath_light" = {
              state = "on";
              attributes = {
                brightness = 100;
              };
            };
          };
        }
      ];
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
