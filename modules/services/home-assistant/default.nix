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

  # Helper function to create motion-activated light automations
  # This reduces duplication for the common pattern of:
  # Motion detected -> Turn on light -> Wait for no motion -> Delay -> Turn off light
  mkMotionLightAutomation = {
    alias,
    motion_sensor,
    target, # { area_id = [...] } or { entity_id = [...] }
    brightness_pct ? null,
    delay_seconds,
    time_condition ? null, # { after = "HH:MM:SS"; before = "HH:MM:SS"; }
    extra_conditions ? [],
    service_type ? "light", # "light" or "switch"
  }: let
    turn_on_service =
      if service_type == "switch"
      then "switch.turn_on"
      else "light.turn_on";
    turn_off_service =
      if service_type == "switch"
      then "switch.turn_off"
      else "light.turn_off";
    turn_on_data =
      if brightness_pct != null
      then {inherit brightness_pct;}
      else {};
  in {
    inherit alias;
    description = "";
    mode = "restart";
    max_exceeded = "silent";
    trigger = {
      platform = "state";
      entity_id = motion_sensor;
      from = "off";
      to = "on";
    };
    condition =
      (lib.optional (time_condition != null) ({condition = "time";} // time_condition))
      ++ extra_conditions;
    action = [
      {
        alias = "Turn on the light";
        service = turn_on_service;
        inherit target;
        data = turn_on_data;
      }
      {
        alias = "Wait until there is no motion from sensor";
        wait_for_trigger = {
          platform = "state";
          entity_id = motion_sensor;
          from = "on";
          to = "off";
        };
      }
      {
        alias = "Wait for ${toString (delay_seconds / 60)} minutes";
        delay = delay_seconds;
      }
      {
        alias = "Turn off the light";
        service = turn_off_service;
        inherit target;
      }
    ];
  };

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
            pkgs.hass-catppuccin
            pkgs.hass-bubble-card
            pkgs.lovelace-auto-entities
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
            "zha"
            "icloud"
            "systemmonitor"
            "energy"
            "matter"
            "thread"
          ];

          # Custom components (HACS-style)
          customComponents = [
            pkgs.home-assistant-custom-components.spook
            pkgs.home-assistant-custom-components.localtuya
            pkgs.home-assistant-custom-components.yoto_ha
            pkgs.home-assistant-custom-components.adaptive_lighting
            (pkgs.buildHomeAssistantComponent rec {
              owner = "AlexxIT";
              domain = "sonoff";
              version = "3.9.3";
              src = pkgs.fetchFromGitHub {
                owner = "AlexxIT";
                repo = "SonoffLAN";
                rev = "v${version}";
                sha256 = "sha256-QqJIPyITFYGD8OkbRTh//F0PWY9BFyhBbJaNtSIQ9tA=";
              };
              propagatedBuildInputs = [
                pkgs.python313Packages.pycryptodome
              ];
            })
            (pkgs.buildHomeAssistantComponent rec {
              owner = "amosyuen";
              domain = "tplink_deco";
              version = "3.7.0";
              src = pkgs.fetchFromGitHub {
                owner = "amosyuen";
                repo = "ha-tplink-deco";
                rev = "v${version}";
                sha256 = "sha256-D0IuB0tbHW/KlYpwug01g0vq+Kpigm8urbpbxpFCUN0=";
              };
              propagatedBuildInputs = [
                pkgs.python313Packages.pycryptodome
              ];
            })
            (pkgs.buildHomeAssistantComponent {
              owner = "maximoei";
              domain = "robovac";
              version = "1.0.0";
              src = pkgs.fetchFromGitHub {
                owner = "maximoei";
                repo = "robovac";
                rev = "ca5ce8b5f65664899f0dc184d131b68021c2737b";
                sha256 = "sha256-xUha26YiSKY+5aRmZviHFqyPLUqOdN6/L/Ikcpe/YH0=";
              };
              propagatedBuildInputs = [
                pkgs.python313Packages.pycryptodome
              ];
            })
            (pkgs.buildHomeAssistantComponent rec {
              owner = "AlexandrErohin";
              domain = "tplink_router";
              version = "2.14.1";
              src = pkgs.fetchFromGitHub {
                owner = "AlexandrErohin";
                repo = "home-assistant-tplink-router";
                rev = "v${version}";
                sha256 = "sha256-5lcyg/WjgXZ/abL50CT0FFpcvozSYIa79Vj/cYQe+aU=";
              };
              propagatedBuildInputs = [
                pkgs.python313Packages.pycryptodome
                (
                  pkgs.python313.pkgs.buildPythonPackage rec {
                    pname = "tplinkrouterc6u";
                    version = "5.12.1";
                    pyproject = true;
                    src = pkgs.fetchPypi {
                      inherit pname version;
                      hash = "sha256-xcr7W1X2nSZQT1/dz4aMxEr+27d5JFdsBGsCCdxki6U=";
                    };
                    propagatedBuildInputs = with pkgs.python313Packages; [
                      setuptools
                      pycryptodome
                      requests
                      macaddress
                    ];
                  }
                )
              ];
            })
            (pkgs.buildHomeAssistantComponent rec {
              owner = "BottlecapDave";
              domain = "octopus_energy";
              version = "17.1.1";
              src = pkgs.fetchFromGitHub {
                owner = "BottlecapDave";
                repo = "HomeAssistant-OctopusEnergy";
                rev = "v${version}";
                sha256 = "sha256-L1LqH9QMasVCZdsnHpKdxYGpsc/2vaIPAbiYc6vVshM=";
              };
              propagatedBuildInputs = with pkgs.python313Packages; [
                pydantic
              ];
            })
            (pkgs.buildHomeAssistantComponent rec {
              owner = "marq24";
              domain = "fordpass";
              version = "2025.11.4";
              src = pkgs.fetchFromGitHub {
                owner = "marq24";
                repo = "ha-fordpass";
                rev = version;
                sha256 = "sha256-FdGPNfdA/x3bv3a1yaOlRdI8+EdXI1LoJFYWW4l/Dvg=";
              };
            })
            (pkgs.buildHomeAssistantComponent rec {
              owner = "vasqued2";
              domain = "teamtracker";
              version = "0.14.9";
              src = pkgs.fetchFromGitHub {
                owner = "vasqued2";
                repo = "ha-teamtracker";
                rev = "v${version}";
                sha256 = "sha256-UCWsprFkoEtBnoiemegmqPMawJ1/j0bpWaz4qNVTt9k=";
              };
              propagatedBuildInputs = with pkgs.python313Packages; [
                arrow
                aiofiles
              ];
            })
            (pkgs.buildHomeAssistantComponent rec {
              owner = "libdyson-wg";
              domain = "dyson_local";
              version = "1.5.7";
              src = pkgs.fetchFromGitHub {
                owner = "libdyson-wg";
                repo = "ha-dyson";
                rev = "v${version}";
                sha256 = "sha256-V5RCepikTDrjZwi6MfRislpV2F9jR1MqwWxTq0GPBp4=";
              };
            })
            (pkgs.buildHomeAssistantComponent rec {
              owner = "twrecked";
              domain = "aarlo";
              version = "0.8.1.19";
              src = pkgs.fetchFromGitHub {
                owner = "twrecked";
                repo = "hass-aarlo";
                rev = "v${version}";
                sha256 = "sha256-M5M/kNUzplv+PuVQAWy0wdw4XXgho67zcvmW9QAXxTk=";
              };
              propagatedBuildInputs = [
                pkgs.python313Packages.unidecode
                pkgs.python313Packages.aiofiles
                (
                  pkgs.python313.pkgs.buildPythonPackage rec {
                    pname = "pyaarlo";
                    version = "0.8.0.17";
                    pyproject = true;
                    src = pkgs.fetchPypi {
                      inherit pname version;
                      hash = "sha256-a7/MnUfzatdNY4RolJd2EsEucDwVoFIXnsYOGtJSGZU=";
                    };
                    propagatedBuildInputs = with pkgs.python313Packages; [
                      setuptools
                      requests
                      click
                      pycryptodome
                      unidecode
                      cloudscraper
                      paho-mqtt
                      cryptography
                      aiofiles
                      python-slugify
                    ];
                  }
                )
              ];
            })
          ];

          # Main Home Assistant configuration
          config = {
            default_config = {};
            logger = {
              logs = {};
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
            mobile_app = {};
            frontend.themes = "!include ${theme}/${theme.pname}.yaml";
            history = {};
            config = {};
            system_health = {};
            lovelace =
              {
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
                  "binary_sensor.motion_sensor_motion"
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

            # Automations
            "automation manual" = [
              # Living Room light dimmer (blueprint-based)
              {
                alias = "Living Room light dimmer";
                description = "";
                use_blueprint = {
                  path = "dieneuser/zha-remote-tradfri-wireless-dimmer-ictc-g-1-for-light.yaml";
                  input = {
                    remote = "13cdd5f70e7ee5f53a8ba526fb1969a9";
                    light = "light.living_room_light";
                  };
                };
              }

              # Motion-activated lighting automations
              (mkMotionLightAutomation {
                alias = "Hallway lights";
                motion_sensor = "binary_sensor.hallway_motion_sensor_occupancy";
                target.area_id = ["hallway"];
                brightness_pct = 10;
                delay_seconds = 60;
              })

              (mkMotionLightAutomation {
                alias = "Bathroom lights (day)";
                motion_sensor = "binary_sensor.motion_sensor_motion";
                target.area_id = ["bathroom"];
                brightness_pct = 85;
                delay_seconds = 300;
                time_condition = {
                  after = "07:30:00";
                  before = "20:00:00";
                };
              })

              (mkMotionLightAutomation {
                alias = "Bathroom lights (night)";
                motion_sensor = "binary_sensor.motion_sensor_motion";
                target.area_id = ["bathroom"];
                brightness_pct = 10;
                delay_seconds = 300;
                time_condition = {
                  before = "07:30:00";
                  after = "20:00:00";
                };
              })

              (mkMotionLightAutomation {
                alias = "Fairy lights";
                motion_sensor = "binary_sensor.aarlo_motion_nursery";
                target.entity_id = ["switch.fairy_lights_switch"];
                delay_seconds = 600;
                time_condition = {
                  after = "20:00:00";
                  before = "23:59:00";
                };
                service_type = "switch";
              })

              (mkMotionLightAutomation {
                alias = "Bedroom lights (night)";
                motion_sensor = "binary_sensor.bedroom_motion_sensor_occupancy";
                target.entity_id = ["light.bedroom_light_2"];
                brightness_pct = 5;
                delay_seconds = 300;
                time_condition = {
                  before = "01:00:00";
                  after = "20:00:00";
                };
                extra_conditions = [
                  {
                    condition = "state";
                    entity_id = "light.bedroom_light_2";
                    state = "off";
                  }
                ];
              })

              (mkMotionLightAutomation {
                alias = "Living room lights (night)";
                motion_sensor = "binary_sensor.living_room_motion_sensor_occupancy";
                target.entity_id = ["light.living_room_light"];
                brightness_pct = 20;
                delay_seconds = 300;
                time_condition = {
                  before = "01:00:00";
                  after = "20:00:00";
                };
                extra_conditions = [
                  {
                    condition = "state";
                    entity_id = "light.living_room_light";
                    state = "off";
                  }
                ];
              })

              # Away from home notifications
              {
                alias = "Away notifications";
                description = "";
                trigger = [
                  {
                    platform = "state";
                    entity_id = ["group.motion"];
                    from = null;
                    to = "on";
                  }
                ];
                condition = [
                  {
                    condition = "not";
                    conditions = [
                      {
                        condition = "zone";
                        entity_id = "person.darren_gilbert";
                        zone = "zone.home";
                      }
                      {
                        condition = "zone";
                        entity_id = "person.lorraine";
                        zone = "zone.home";
                      }
                    ];
                  }
                ];
                action = [
                  {
                    service = "notify.mobile_app_hatchling";
                    data = {
                      title = "Motion detected";
                      message = "Detected a motion: {{ ( expand('group.motion') | sort(reverse=true, attribute='last_changed') | map(attribute='name') | list )[0] }}";
                    };
                  }
                ];
                mode = "queued";
                max = 5;
              }

              # Low battery alert notifications
              {
                alias = "Low battery notifications";
                description = "Alert when device batteries are low";
                trigger = [
                  {
                    platform = "numeric_state";
                    entity_id = [
                      "sensor.hallway_motion_sensor_battery"
                      "sensor.motion_sensor_battery"
                      "sensor.bedroom_motion_sensor_battery"
                      "sensor.living_room_motion_sensor_battery"
                    ];
                    below = 20;
                  }
                ];
                action = [
                  {
                    service = "notify.mobile_app_hatchling";
                    data = {
                      title = "Low Battery Alert";
                      message = "{{ trigger.to_state.attributes.friendly_name }} battery is at {{ trigger.to_state.state }}%";
                      data = {
                        priority = "high";
                      };
                    };
                  }
                ];
                mode = "queued";
                max = 10;
              }

              # iPad low battery notification
              {
                alias = "iPad low battery";
                trigger = [
                  {
                    platform = "numeric_state";
                    entity_id = "sensor.lorraines_ipad_battery_level";
                    below = 10;
                  }
                ];
                action = [
                  {
                    action = "notify.mobile_app_hatchling";
                    data = {
                      title = "Please";
                      message = "Change the iPad";
                    };
                  }
                ];
                mode = "single";
              }

              # TV Light - turn on when TV turns on (evening)
              {
                alias = "TV Light - On";
                trigger = [
                  {
                    platform = "state";
                    entity_id = "media_player.lg_webos_smart_tv";
                    to = "on";
                  }
                ];
                condition = [
                  {
                    condition = "time";
                    after = "17:00:00";
                    before = "06:00:00";
                  }
                ];
                action = [
                  {
                    action = "light.turn_on";
                    target.entity_id = "light.tv_light";
                    data = {
                      kelvin = 6031;
                      brightness_pct = 100;
                    };
                  }
                ];
                mode = "single";
              }

              # TV Light - turn off when TV turns off
              {
                alias = "TV Lights - Off";
                trigger = [
                  {
                    platform = "state";
                    entity_id = "media_player.lg_webos_smart_tv";
                    to = "off";
                  }
                ];
                action = [
                  {
                    action = "light.turn_off";
                    target.entity_id = "light.tv_light";
                  }
                ];
                mode = "single";
              }

              # Dishwasher complete notification
              {
                alias = "Dishwasher complete";
                trigger = [
                  {
                    platform = "state";
                    entity_id = "binary_sensor.dishwasher_vibration";
                    to = "on";
                  }
                ];
                action = [
                  {
                    wait_for_trigger = [
                      {
                        platform = "state";
                        entity_id = "binary_sensor.dishwasher_vibration";
                        to = "off";
                        for.minutes = 5;
                      }
                    ];
                  }
                  {
                    action = "notify.notify";
                    data = {
                      title = "Dishwasher";
                      message = "Dishwasher should be finished!";
                    };
                  }
                  {
                    action = "notify.lg_webos_smart_tv";
                    data = {
                      title = "Dishwasher";
                      message = "Dishwasher";
                    };
                  }
                ];
                mode = "restart";
              }

              # Washing machine complete notification
              {
                alias = "Washing machine complete";
                trigger = [
                  {
                    platform = "numeric_state";
                    entity_id = "sensor.sonoff_10022b2169_power";
                    above = 50;
                  }
                ];
                action = [
                  {
                    wait_for_trigger = [
                      {
                        platform = "numeric_state";
                        entity_id = "sensor.sonoff_10022b2169_power";
                        below = 50;
                        for.minutes = 5;
                      }
                    ];
                  }
                  {
                    action = "notify.notify";
                    data = {
                      title = "Washing machine";
                      message = "Washing machine should be finished!";
                    };
                  }
                  {
                    action = "notify.lg_webos_smart_tv";
                    data = {
                      title = "Washing machine";
                      message = "Washing machine";
                    };
                  }
                ];
                mode = "restart";
              }

              # Auto turn off LG TV when Apple TV turns off
              {
                alias = "Automatically turn off TV";
                trigger = [
                  {
                    platform = "state";
                    entity_id = "remote.apple_tv";
                    to = "off";
                  }
                ];
                action = [
                  {
                    action = "media_player.turn_off";
                    target.entity_id = "media_player.lg_webos_smart_tv";
                  }
                ];
                mode = "single";
              }

              # Leave Home - turn off all devices when everyone leaves
              {
                alias = "Leave Home";
                trigger = [
                  {
                    platform = "zone";
                    entity_id = "person.darren_gilbert";
                    zone = "zone.home";
                    event = "leave";
                  }
                  {
                    platform = "zone";
                    entity_id = "person.lorraine";
                    zone = "zone.home";
                    event = "leave";
                  }
                ];
                condition = [
                  {
                    condition = "not";
                    conditions = [
                      {
                        condition = "zone";
                        entity_id = "person.darren_gilbert";
                        zone = "zone.home";
                      }
                      {
                        condition = "zone";
                        entity_id = "person.lorraine";
                        zone = "zone.home";
                      }
                    ];
                  }
                ];
                action = [
                  {
                    action = "light.turn_off";
                    target.entity_id = [
                      "light.tv_light"
                      "light.living_room_light"
                      "light.dining_room_light_3"
                      "light.sofa_light_switch"
                      "light.hallway"
                      "light.doorway"
                      "light.kitchen_microwave"
                      "light.kitchen_sink"
                      "light.kitchen_random"
                      "light.bath_light"
                      "light.sink_light"
                      "light.toilet_light"
                      "light.above_bed_light"
                      "light.bedroom_light_2"
                      "light.darren_switch"
                      "light.lorraine_switch"
                      "light.robynne_light"
                      "light.fairy_lights_switch"
                    ];
                  }
                  {
                    action = "media_player.turn_off";
                    target.entity_id = [
                      "media_player.apple_tv"
                      "media_player.lg_webos_smart_tv"
                      "media_player.homepod_2"
                    ];
                  }
                  {
                    action = "fan.turn_off";
                    target.entity_id = "fan.dyson";
                  }
                  {
                    action = "switch.turn_off";
                    target.entity_id = "switch.security_camera_privacy_mode";
                  }
                ];
                mode = "single";
              }

              # Enter Home - enable camera privacy when someone arrives
              {
                alias = "Enter Home";
                trigger = [
                  {
                    platform = "zone";
                    entity_id = "person.darren_gilbert";
                    zone = "zone.home";
                    event = "enter";
                  }
                  {
                    platform = "zone";
                    entity_id = "person.lorraine";
                    zone = "zone.home";
                    event = "enter";
                  }
                ];
                action = [
                  {
                    action = "switch.turn_on";
                    target.entity_id = "switch.security_camera_privacy_mode";
                  }
                ];
                mode = "single";
              }

              # Party Mode - use blueprint for party lights
              {
                alias = "Party Mode";
                use_blueprint = {
                  path = "Twanne/party_lights.yaml";
                  input = {
                    party_mode_trigger = "input_boolean.party_mode";
                    target_lights = [
                      "light.tv_light"
                      "light.living_room_light"
                    ];
                    color_mode = "random";
                    min_brightness_pct = 20;
                    time_between_changes = {
                      seconds = 5;
                    };
                    transition_time = 3;
                  };
                };
              }

              # Humidity Extractor - toggle extractor when humidity is high
              {
                alias = "Humidity Extractor";
                trigger = [
                  {
                    platform = "numeric_state";
                    entity_id = "sensor.bathroom_sensor_humidity";
                    above = 70;
                  }
                ];
                action = [
                  {
                    action = "switch.toggle";
                    target.entity_id = "switch.fingerbot_extractor_switch";
                  }
                  {delay.minutes = 30;}
                ];
                mode = "single";
              }
            ];
          };
        };
      };
    };
  }
