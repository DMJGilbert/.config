{
  config,
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
    ./../modules/home-assistant/dashboard.nix
    ./shared.nix
  ];

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

  # Intel MacBook Pro hardware support
  hardware = {
    cpu.intel.updateMicrocode = true;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # VAAPI for Broadwell+ Intel GPUs
        intel-vaapi-driver # VAAPI for older Intel GPUs
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # Zram swap for better performance than disk swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Ensure hass user can access serial devices
  users.users.hass.extraGroups = ["dialout"];

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

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "dmjgilbert@gmail.com";

  services = {
    # Zigbee USB dongle configuration
    udev.extraRules = ''
      # Sonoff Zigbee 3.0 USB Dongle Plus - disable autosuspend and set permissions
      SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0660", GROUP="dialout", SYMLINK+="zigbee"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTR{power/autosuspend}="-1"
    '';

    # Disable services that interfere with USB serial devices
    brltty.enable = false;

    # Intel MacBook thermal management
    thermald.enable = true;

    # Power management for laptop
    auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          governor = "performance";
          turbo = "auto";
        };
        battery = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };

    # SSD TRIM for longevity
    fstrim.enable = true;

    # Prevent system freeze under memory pressure
    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
    };

    logind.settings.Login.HandleLidSwitch = "ignore";

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    tailscale.enable = true;

    adguardhome = {
      enable = true;
      mutableSettings = true;
    };

    nginx = {
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

    matter-server = {
      enable = true;
      port = 5580;
    };

    home-assistant = {
      enable = true;
      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        pkgs.hass-catppuccin
        pkgs.hass-bubble-card
        pkgs.lovelace-auto-entities
        pkgs.lovelace-tabbed-card
        pkgs.lovelace-layout-card
        pkgs.lovelace-stack-in-card
        pkgs.modern-circular-gauge
        pkgs.ha-floorplan
        mini-graph-card
        multiple-entity-row
        decluttering-card
        button-card
        lg-webos-remote-control
        light-entity-card
        mushroom
        card-mod
        apexcharts-card
      ];
      extraPackages = python3Packages:
        with python3Packages; [
          isal
          zlib-ng
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
          radius = 50;
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
        # camera = [
        #   {
        #     platform = "ffmpeg";
        #     name = "local_usb_cam";
        #     input = "/dev/video0";
        #     extra_arguments = "-f video4linux2";
        #   }
        # ];
        mobile_app = {};
        frontend.themes = "!include ${theme}/${theme.pname}.yaml";
        history = {};
        config = {};
        system_health = {};
        lovelace = {
          mode = "yaml";
          resources = [
            {
              url = "/local/nixos-lovelace-modules/bubble-card.js";
              type = "module";
            }
            {
              url = "/local/nixos-lovelace-modules/tabbed-card.js";
              type = "module";
            }
            {
              url = "/local/nixos-lovelace-modules/auto-entities.js";
              type = "module";
            }
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
            {
              url = "/local/nixos-lovelace-modules/card-mod.js";
              type = "module";
            }
            {
              url = "/local/nixos-lovelace-modules/apexcharts-card.js";
              type = "module";
            }
            {
              url = "/local/nixos-lovelace-modules/layout-card.js";
              type = "module";
            }
            {
              url = "/local/nixos-lovelace-modules/stack-in-card.js";
              type = "module";
            }
            {
              url = "/local/nixos-lovelace-modules/modern-circular-gauge.js";
              type = "module";
            }
            {
              url = "/local/nixos-lovelace-modules/floorplan.js";
              type = "module";
            }
          ];
        };
        ffmpeg = {};
        energy = {};
        sensor = [
          {
            platform = "systemmonitor";
            resources = [
              {
                type = "disk_use_percent";
                arg = "/";
              }
              {type = "memory_use_percent";}
              {type = "processor_use";}
              {type = "processor_temperature";}
              {type = "load_1m";}
              {type = "load_5m";}
              {type = "load_15m";}
            ];
          }
        ];
        template = [
          {
            sensor = {
              name = "Total Turned On Lights Count Template";
              state = "{{ states.light | rejectattr('attributes.entity_id', 'defined') | selectattr('state', 'eq', 'on') | list | count }}";
            };
          }
          {
            sensor = {
              name = "Total Active Motion Sensors Count Template";
              state = "{{ states.binary_sensor | selectattr('attributes.device_class', 'eq', 'motion') |
            selectattr('state', 'eq', 'on') | list | count + states.binary_sensor |
            selectattr('attributes.device_class', 'eq', 'occupancy') | selectattr('state', 'eq', 'on') | list | count
            }}";
            };
          }
          {
            sensor = {
              name = "Total Media Players Playing Template";
              state = "{{ states.media_player | selectattr('state', 'eq', 'playing') | list | count }}";
            };
          }
        ];
        group = {
          motion = {
            name = "Home motion";
            entities = [
              # "binary_sensor.aarlo_motion_nursery"
              "binary_sensor.motion_sensor_motion"
              # "binary_sensor.robynne_motion_sensor_occupancy"
              "binary_sensor.bedroom_motion_sensor_occupancy"
              "binary_sensor.hallway_motion_sensor_occupancy"
              "binary_sensor.living_room_motion_sensor_occupancy"
            ];
          };
          hallway_lights = {
            name = "Hallway Lights";
            entities = [
              "light.doorway"
              "light.hallway"
            ];
          };
          living_room_lights = {
            name = "Living Room Lights";
            entities = [
              "light.living_room_light"
              "light.dining_room_light_3"
              "light.sofa_light_switch"
            ];
          };
          kitchen_lights = {
            name = "Kitchen Lights";
            entities = [
              "light.kitchen_microwave"
              "light.kitchen_sink"
              "light.kitchen_random"
            ];
          };
          bathroom_lights = {
            name = "Bathroom Lights";
            entities = [
              "light.bath_light"
              "light.sink_light"
              "light.toilet_light"
            ];
          };
          bedroom_lights = {
            name = "Bedroom Lights";
            entities = [
              "light.above_bed_light"
              "light.bedroom_light_2"
              "light.darren_switch"
              "light.lorraine_switch"
            ];
          };
          robynne_lights = {
            name = "Robynne Lights";
            entities = [
              "light.robynne_light"
              "light.aarlo_nursery"
              "light.fairy_lights_switch"
            ];
          };
        };
        scene = [];
        input_boolean = {
          party_mode = {
            name = "Party Mode";
            icon = "mdi:party-popper";
          };
          outdoor_lights = {
            name = "Outdoor Lights";
            icon = "mdi:string-lights";
          };
        };
        script = {
          robynnes_playlist = {
            alias = "Robynnes Playlist";
            icon = "mdi:account-music";
            sequence = [
              {
                action = "media_player.play_media";
                target.entity_id = "media_player.apple_tv";
                data = {
                  media_content_id = "https://music.apple.com/gb/playlist/robynnes/pl.u-vxJXsWbo9Pl";
                  media_content_type = "url";
                };
              }
              {delay.seconds = 3;}
              {
                action = "remote.send_command";
                target.entity_id = "remote.apple_tv";
                data = {
                  command = ["right" "select"];
                  delay_secs = 1;
                };
              }
            ];
          };
          play_media = {
            alias = "Play Media";
            icon = "mdi:video";
            fields = {
              media_url = {
                description = "URL of media to play";
                example = "https://example.com/video.mp4";
              };
            };
            sequence = [
              {
                action = "media_player.play_media";
                target.entity_id = "media_player.apple_tv";
                data = {
                  media_content_id = "{{ media_url }}";
                  media_content_type = "url";
                };
              }
              {delay.seconds = 5;}
              {
                action = "remote.send_command";
                target.entity_id = "remote.apple_tv";
                data = {
                  command = "select";
                  delay_secs = 0.4;
                };
              }
            ];
          };
        };
      };
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
