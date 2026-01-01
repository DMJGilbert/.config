# Home Assistant automations
# Extracted from default.nix for maintainability
{lib}: let
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
in [
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
          "light.kajplats_e27_ws_g95_clear_806lm"
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

  # =============================================================================
  # BILRESA Living Room Control - Button 1 (Living/Dining Lights)
  # =============================================================================

  # Button 1 Press - Toggle living room and dining room lights
  {
    alias = "BILRESA Button 1 - Toggle Lights";
    description = "Toggle living room and dining room lights on button 1 press";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_3";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_1' }}";
      }
    ];
    action = [
      {
        action = "light.toggle";
        target.entity_id = [
          "light.living_room_light"
          "light.dining_room_light_3"
        ];
      }
    ];
    mode = "single";
  }

  # Button 1 Rotate CW - Increase brightness
  {
    alias = "BILRESA Button 1 - Brightness Up";
    description = "Increase living/dining room brightness on clockwise rotation";
    trigger = [
      {
        platform = "event";
        event_type = "state_changed";
        event_data = {
          entity_id = "event.bilresa_scroll_wheel_button_1";
        };
      }
    ];
    action = [
      {
        action = "light.turn_on";
        target.entity_id = [
          "light.living_room_light"
          "light.dining_room_light_3"
        ];
        data = {
          # Scale brightness by number of scroll clicks (5% per click)
          brightness_step_pct = "{{ trigger.event.data.new_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
        };
      }
    ];
    mode = "single";
  }

  # Button 1 Rotate CCW - Decrease brightness
  {
    alias = "BILRESA Button 1 - Brightness Down";
    description = "Decrease living/dining room brightness on counter-clockwise rotation";
    trigger = [
      {
        platform = "event";
        event_type = "state_changed";
        event_data = {
          entity_id = "event.bilresa_scroll_wheel_button_2";
        };
      }
    ];
    action = [
      {
        action = "light.turn_on";
        target.entity_id = [
          "light.living_room_light"
          "light.dining_room_light_3"
        ];
        data = {
          # Scale brightness by number of scroll clicks (5% per click)
          brightness_step_pct = "{{ -1 * trigger.event.data.new_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
        };
      }
    ];
    mode = "single";
  }

  # =============================================================================
  # BILRESA Living Room Control - Button 2 (Sofa Light)
  # =============================================================================

  # Button 2 Press - Toggle sofa light
  {
    alias = "BILRESA Button 2 - Toggle Sofa Light";
    description = "Toggle sofa light on button 2 press";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_6";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_1' }}";
      }
    ];
    action = [
      {
        action = "light.toggle";
        target.entity_id = "light.kajplats_e27_ws_g95_clear_806lm";
      }
    ];
    mode = "single";
  }

  # Button 2 Rotate CW - Increase brightness
  {
    alias = "BILRESA Button 2 - Sofa Brightness Up";
    description = "Increase sofa light brightness on clockwise rotation";
    trigger = [
      {
        platform = "event";
        event_type = "state_changed";
        event_data = {
          entity_id = "event.bilresa_scroll_wheel_button_4";
        };
      }
    ];
    action = [
      {
        action = "light.turn_on";
        target.entity_id = "light.kajplats_e27_ws_g95_clear_806lm";
        data = {
          # Scale brightness by number of scroll clicks (5% per click)
          brightness_step_pct = "{{ trigger.event.data.new_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
        };
      }
    ];
    mode = "single";
  }

  # Button 2 Rotate CCW - Decrease brightness
  {
    alias = "BILRESA Button 2 - Sofa Brightness Down";
    description = "Decrease sofa light brightness on counter-clockwise rotation";
    trigger = [
      {
        platform = "event";
        event_type = "state_changed";
        event_data = {
          entity_id = "event.bilresa_scroll_wheel_button_5";
        };
      }
    ];
    action = [
      {
        action = "light.turn_on";
        target.entity_id = "light.kajplats_e27_ws_g95_clear_806lm";
        data = {
          # Scale brightness by number of scroll clicks (5% per click)
          brightness_step_pct = "{{ -1 * trigger.event.data.new_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
        };
      }
    ];
    mode = "single";
  }

  # =============================================================================
  # BILRESA Living Room Control - Button 3 (TV Control)
  # =============================================================================

  # Button 3 Single Press - Play/Pause Apple TV
  {
    alias = "BILRESA Button 3 - TV Play/Pause";
    description = "Play/pause Living Room TV on single press";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_9";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_1' }}";
      }
    ];
    action = [
      {
        action = "media_player.media_play_pause";
        target.entity_id = "media_player.living_room_tv";
      }
    ];
    mode = "single";
  }

  # Button 3 Double Press - Toggle HDMI1/HDMI2 on LG TV
  {
    alias = "BILRESA Button 3 - Switch HDMI";
    description = "Toggle between HDMI1 and HDMI2 on double press";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_9";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_2' }}";
      }
    ];
    action = [
      {
        action = "media_player.select_source";
        target.entity_id = "media_player.lg_webos_smart_tv";
        data = {
          source = "{{ 'HDMI2' if state_attr('media_player.lg_webos_smart_tv', 'source') == 'HDMI1' else 'HDMI1' }}";
        };
      }
    ];
    mode = "single";
  }

  # Button 3 Long Press - Toggle LG TV Power
  {
    alias = "BILRESA Button 3 - TV Power";
    description = "Toggle LG TV power on long press";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_9";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = "{{ trigger.to_state.attributes.event_type == 'long_release' }}";
      }
    ];
    action = [
      {
        choose = [
          {
            conditions = [
              {
                condition = "state";
                entity_id = "media_player.lg_webos_smart_tv";
                state = "off";
              }
            ];
            sequence = [
              {
                action = "media_player.turn_on";
                target.entity_id = "media_player.lg_webos_smart_tv";
              }
            ];
          }
        ];
        default = [
          {
            action = "media_player.turn_off";
            target.entity_id = "media_player.lg_webos_smart_tv";
          }
        ];
      }
    ];
    mode = "single";
  }

  # Button 3 Rotate CW - Volume Up
  # Controls Apple TV volume on HDMI1, LG TV volume otherwise
  {
    alias = "BILRESA Button 3 - Volume Up";
    description = "Increase volume on clockwise rotation";
    trigger = [
      {
        platform = "event";
        event_type = "state_changed";
        event_data = {
          entity_id = "event.bilresa_scroll_wheel_button_7";
        };
      }
    ];
    action = [
      {
        repeat = {
          count = "{{ trigger.event.data.new_state.attributes.totalNumberOfPressesCounted | default(1) | int }}";
          sequence = [
            {
              action = "media_player.volume_up";
              target.entity_id = "{{ 'media_player.living_room_tv' if state_attr('media_player.lg_webos_smart_tv', 'source') == 'HDMI1' else 'media_player.lg_webos_smart_tv' }}";
            }
          ];
        };
      }
    ];
    mode = "single";
  }

  # Button 3 Rotate CCW - Volume Down
  # Controls Apple TV volume on HDMI1, LG TV volume otherwise
  {
    alias = "BILRESA Button 3 - Volume Down";
    description = "Decrease volume on counter-clockwise rotation";
    trigger = [
      {
        platform = "event";
        event_type = "state_changed";
        event_data = {
          entity_id = "event.bilresa_scroll_wheel_button_8";
        };
      }
    ];
    action = [
      {
        repeat = {
          count = "{{ trigger.event.data.new_state.attributes.totalNumberOfPressesCounted | default(1) | int }}";
          sequence = [
            {
              action = "media_player.volume_down";
              target.entity_id = "{{ 'media_player.living_room_tv' if state_attr('media_player.lg_webos_smart_tv', 'source') == 'HDMI1' else 'media_player.lg_webos_smart_tv' }}";
            }
          ];
        };
      }
    ];
    mode = "single";
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
]
