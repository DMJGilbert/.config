{
  config,
  lib,
  pkgs,
  currentSystem,
  ...
}: let
  cfg = config.local.services.homeAssistant;
  isLinux = builtins.match ".*-linux" currentSystem != null;
  theme = pkgs.hass-catppuccin;

  # Import extracted modules
  automations = import ./automations.nix {inherit lib;};
  customComponents = import ./custom-components.nix {inherit pkgs;};

  # Dashboard file paths - these are relative to the module directory
  moduleDir = ./.;
  dashboardYaml = pkgs.writeText "home.yaml" (builtins.readFile "${moduleDir}/dashboard.yaml");
  floorplanSvg = "${moduleDir}/floorplan.svg";
  viewsDir = "${moduleDir}/views";
  templatesDir = "${moduleDir}/templates";
  popupsDir = "${moduleDir}/popups";
in
  # Only define options on all platforms; config only on Linux
  {
    options.local.services.homeAssistant = {
      enable = lib.mkEnableOption "Home Assistant home automation";

      matterServer = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Matter server for Thread/Matter device support";
        };
      };

      dashboard = {
        enable = lib.mkEnableOption "YAML-mode Lovelace dashboard";
      };
    };

    # Warn if enabled on unsupported platform
    config.warnings =
      lib.optional (!isLinux && cfg.enable)
      "local.services.homeAssistant is only supported on NixOS (Linux). This option has no effect on darwin.";
  }
  // lib.optionalAttrs isLinux {
    # NixOS-specific config - these options don't exist on darwin
    config = lib.mkIf cfg.enable {
      # Ensure hass user can access serial devices (for Zigbee USB dongle)
      users.users.hass.extraGroups = ["dialout"];

      # Dashboard file symlinks (conditional on dashboard.enable)
      systemd.tmpfiles.rules = lib.mkIf cfg.dashboard.enable [
        "L+ /var/lib/hass/home.yaml - - - - ${dashboardYaml}"
        "L+ /var/lib/hass/floorplan.svg - - - - ${floorplanSvg}"
        "L+ /var/lib/hass/views - - - - ${viewsDir}"
        "L+ /var/lib/hass/templates - - - - ${templatesDir}"
        "L+ /var/lib/hass/popups - - - - ${popupsDir}"
      ];

      # Enable Matter server when configured (for Thread/Matter devices)
      local.services.matterServer.enable = cfg.matterServer.enable;

      services = {
        # Zigbee USB dongle configuration
        udev.extraRules = ''
          # Sonoff Zigbee 3.0 USB Dongle Plus - disable autosuspend and set permissions
          SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0660", GROUP="dialout", SYMLINK+="zigbee"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", ATTR{power/autosuspend}="-1"
        '';

        # Disable services that interfere with USB serial devices
        brltty.enable = false;

        home-assistant = {
          enable = true;

          # Custom Lovelace modules
          customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
            bubble-card
            auto-entities
            pkgs.lovelace-tabbed-card
            pkgs.lovelace-layout-card
            pkgs.lovelace-stack-in-card
            pkgs.lovelace-state-switch
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

          # Custom components (HACS-style) - imported from custom-components.nix
          inherit customComponents;

          # Extra Python packages
          extraPackages = python3Packages:
            with python3Packages; [
              isal
              zlib-ng
            ];

          # Extra components from nixpkgs
          extraComponents = [
            "esphome"
            "met"
            "google_translate"
            "calendar"
            "caldav"
            "radio_browser"
            "light"
            "blueprint"
            "lovelace"
            "tailscale"
            "adguard"
            "bluetooth"
            "automation"
            "tplink"
            "nmap_tracker"
            "onvif"
            "hue"
            "apple_tv"
            "itunes"
            "weatherkit"
            "webostv"
            "homekit"
            "homekit_controller"
            "zeroconf"
            "tuya"
            "twinkly"
            "mqtt"
            "icloud"
            "systemmonitor"
            "energy"
            "matter"
            "thread"
            "london_underground"
            "glances"
            "uptimekuma"
          ];

          # Main Home Assistant configuration
          config = {
            default_config = {};
            logger = {};
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
              server_host = "127.0.0.1";
              server_port = 8123;
              use_x_forwarded_for = true;
              trusted_proxies = ["127.0.0.1"];
            };
            mobile_app = {};
            frontend.themes = "!include ${theme}/${theme.pname}.yaml";
            history = {};
            config = {};
            system_health = {};
            lovelace =
              {
                resource_mode = "yaml";
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
                    url = "/local/nixos-lovelace-modules/state-switch.js";
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
              }
              // lib.optionalAttrs cfg.dashboard.enable {
                dashboards = {
                  lovelace-home = {
                    mode = "yaml";
                    filename = "home.yaml";
                    title = "Fleming Place";
                    icon = "mdi:home-assistant";
                    show_in_sidebar = true;
                    require_admin = false;
                  };
                };
              };
            ffmpeg = {};
            energy = {};
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
                  name = "Washing Machine Power";
                  unique_id = "washing_machine_power";
                  state = "{{ states('sensor.sonoff_10022b2169_power') }}";
                  unit_of_measurement = "W";
                  device_class = "power";
                  state_class = "measurement";
                };
              }
              {
                sensor = {
                  name = "Total Media Players Playing Template";
                  state = "{{ states.media_player | selectattr('state', 'eq', 'playing') | list | count }}";
                };
              }
              {
                light = [
                  {
                    name = "Darren Switch";
                    unique_id = "darren_switch_light";
                    state = "{{ is_state('switch.darren_switch', 'on') }}";
                    turn_on.action = "switch.turn_on";
                    turn_on.target.entity_id = "switch.darren_switch";
                    turn_off.action = "switch.turn_off";
                    turn_off.target.entity_id = "switch.darren_switch";
                  }
                  {
                    name = "Lorraine Switch";
                    unique_id = "lorraine_switch_light";
                    state = "{{ is_state('switch.lorraine_switch', 'on') }}";
                    turn_on.action = "switch.turn_on";
                    turn_on.target.entity_id = "switch.lorraine_switch";
                    turn_off.action = "switch.turn_off";
                    turn_off.target.entity_id = "switch.lorraine_switch";
                  }
                  {
                    name = "Fairy Lights";
                    unique_id = "fairy_lights_light";
                    state = "{{ is_state('switch.fairy_lights', 'on') }}";
                    turn_on.action = "switch.turn_on";
                    turn_on.target.entity_id = "switch.fairy_lights";
                    turn_off.action = "switch.turn_off";
                    turn_off.target.entity_id = "switch.fairy_lights";
                  }
                ];
              }
            ];
            group = {
              motion = {
                name = "Home motion";
                entities = [
                  "binary_sensor.bathroom_motion_sensor_occupancy"
                  "binary_sensor.bedroom_motion_sensor_occupancy"
                  "binary_sensor.hallway_motion_sensor_occupancy"
                  "binary_sensor.living_room_motion_sensor_occupancy"
                ];
              };
              hallway_lights = {
                name = "Hallway Lights";
                entities = [
                  "light.door"
                  "light.hallway"
                ];
              };
              living_room_lights = {
                name = "Living Room Lights";
                entities = [
                  "light.living_room"
                  "light.dining_room"
                  "light.kajplats_e27_ws_g95_clear_806lm"
                ];
              };
              kitchen_lights = {
                name = "Kitchen Lights";
                entities = [
                  "light.kitchen"
                  "light.kitchen_sink"
                  "light.kitchen_2"
                ];
              };
              bathroom_lights = {
                name = "Bathroom Lights";
                entities = [
                  "light.bath"
                  "light.bathroom_sink"
                  "light.toilet"
                ];
              };
              bedroom_lights = {
                name = "Bedroom Lights";
                entities = [
                  "light.above_bed"
                  "light.bedroom"
                  "light.darren_switch"
                  "light.lorraine_switch"
                ];
              };
              robynne_lights = {
                name = "Robynne Lights";
                entities = [
                  "light.robynne"
                  "light.aarlo_nursery"
                  "light.fairy_lights"
                ];
              };
            };
            adaptive_lighting = [
              {
                name = "Default";
                lights = [
                  "light.living_room"
                  "light.dining_room"
                  "light.kitchen"
                  "light.kitchen_sink"
                  "light.kitchen_2"
                  "light.bedroom"
                  "light.above_bed"
                  "light.hallway"
                  "light.door"
                ];
                min_brightness = 1;
                max_brightness = 100;
                min_color_temp = 2000;
                max_color_temp = 5500;
                sleep_brightness = 1;
                sleep_color_temp = 1000;
                take_over_control = true;
                detect_non_ha_changes = false;
              }
            ];
            scene = {};
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
                    target.entity_id = "media_player.living_room";
                    data = {
                      media_content_id = "https://music.apple.com/gb/playlist/robynnes/pl.u-vxJXsWbo9Pl";
                      media_content_type = "url";
                    };
                  }
                  {delay.seconds = 3;}
                  {
                    action = "remote.send_command";
                    target.entity_id = "remote.living_room";
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
                    target.entity_id = "media_player.living_room";
                    data = {
                      media_content_id = "{{ media_url }}";
                      media_content_type = "url";
                    };
                  }
                  {delay.seconds = 5;}
                  {
                    action = "remote.send_command";
                    target.entity_id = "remote.living_room";
                    data = {
                      command = "select";
                      delay_secs = 0.4;
                    };
                  }
                ];
              };
            };

            # Automations - imported from automations.nix
            "automation manual" = automations;
          };
        };
      };
    };
  }
