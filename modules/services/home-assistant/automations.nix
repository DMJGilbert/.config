# Home Assistant automations
# Extracted from default.nix for maintainability
{lib}: let
  # Helper function to create motion-activated light automations
  # This reduces duplication for the common pattern of:
  # Motion detected -> Turn on light -> Wait for no motion -> Delay -> Turn off light
  mkMotionLightAutomation = {
    id,
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
    inherit id alias;
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

  bathroom = rec {
    nightLight = "light.bath";
    lights = [nightLight "light.bathroom_sink" "light.toilet"];
    motion = "binary_sensor.bathroom_motion_sensor_occupancy";
    timer = "timer.bathroom_lights";
    buttonUp = "event.bathroom_buttons_button_1";
    buttonDown = "event.bathroom_buttons_button_2";
    floorPct = 1;
    stepPct = 10;

    # Jinja fragments over the `lights` automation variable. currentPct is the
    # brightest bathroom light that is on, as a percentage, or 0 when all are off.
    lightsOn = "(expand(lights) | selectattr('state', 'eq', 'on') | list | count > 0)";
    currentPct = "(((([0] + (expand(lights) | selectattr('state', 'eq', 'on') | map(attribute='attributes.brightness') | map('int', 0) | list)) | max) / 2.55) | round(0) | int)";

    setPct = expr: {
      action = "light.turn_on";
      target.entity_id = lights;
      data.brightness_pct = "{{ ${expr} }}";
    };

    turnOnDefault = setPct "default_pct";

    # Dimming to the floor leaves only nightLight on, at floorPct, with the
    # rest off. Brightening goes through setPct, which turns them all back on.
    dimTo = expr: [
      {variables.target_pct = "{{ ${expr} }}";}
      {
        "if" = [
          {
            condition = "template";
            value_template = "{{ target_pct | int <= ${toString floorPct} }}";
          }
        ];
        "then" = [
          {
            action = "light.turn_on";
            target.entity_id = nightLight;
            data.brightness_pct = floorPct;
          }
          {
            action = "light.turn_off";
            target.entity_id = builtins.filter (l: l != nightLight) lights;
          }
        ];
        "else" = [(setPct "target_pct")];
      }
    ];

    # Restarts the full countdown once motion has cleared; while motion is on
    # the timer stays cancelled. It does not check the lights are on: right
    # after light.turn_on their state may not have updated yet, and a timer
    # finishing on lights that are already off is harmless.
    restartTimer = {
      "if" = [
        {
          condition = "state";
          entity_id = motion;
          state = "off";
        }
      ];
      "then" = [
        {
          action = "timer.start";
          target.entity_id = timer;
        }
      ];
    };

    pressed = id: eventType: [
      {
        condition = "trigger";
        inherit id;
      }
      {
        condition = "template";
        value_template = "{{ trigger.to_state.attributes.event_type == '${eventType}' }}";
      }
    ];

    # Holding a button ramps until long_release arrives as a new trigger, which
    # restarts the automation (mode: restart) and so ends this loop. The index
    # cap is a backstop in case the release event is lost.
    ramp = up: {
      repeat = {
        "while" = [
          {
            condition = "template";
            value_template =
              if up
              then "{{ repeat.index <= 30 and ${currentPct} < 100 }}"
              else "{{ repeat.index <= 30 and ${currentPct} > ${toString floorPct} }}";
          }
        ];
        sequence =
          (
            if up
            then [(setPct "[${currentPct} + ${toString stepPct}, 100] | min")]
            else dimTo "[${currentPct} - ${toString stepPct}, ${toString floorPct}] | max"
          )
          ++ [{delay.milliseconds = 300;}];
      };
    };

    buttonTrigger = entity_id: id: {
      platform = "state";
      inherit entity_id id;
      not_from = ["unavailable"];
      not_to = ["unavailable"];
    };
  };
in [
  # Front door entry light - turns on 100% when door opens, off 5 min after
  # the last open. mode=restart means reopening the door restarts the timer.
  {
    id = "front_door_hallway_lights";
    alias = "Front door hallway lights";
    description = "Turn hallway lights to 100% when front door opens, off 5 min after last open";
    trigger = [
      {
        platform = "state";
        entity_id = "binary_sensor.myggbett_door_window_sensor_door";
        to = "on";
      }
    ];
    action = [
      {
        action = "light.turn_on";
        target.area_id = ["hallway"];
        data = {
          brightness_pct = "{{ 100 if today_at('07:30') <= now() < today_at('20:00') else 30 }}";
        };
      }
      {
        alias = "Wait 5 minutes";
        delay = 300;
      }
      {
        action = "light.turn_off";
        target.area_id = ["hallway"];
      }
    ];
    mode = "restart";
  }

  # Motion-activated lighting automations
  (mkMotionLightAutomation {
    id = "hallway_lights_day";
    alias = "Hallway lights (day)";
    motion_sensor = "binary_sensor.hallway_motion_sensor_occupancy";
    target.area_id = ["hallway"];
    brightness_pct = 85;
    delay_seconds = 60;
    time_condition = {
      after = "07:30:00";
      before = "20:00:00";
    };
  })

  (mkMotionLightAutomation {
    id = "hallway_lights_night";
    alias = "Hallway lights (night)";
    motion_sensor = "binary_sensor.hallway_motion_sensor_occupancy";
    target.area_id = ["hallway"];
    brightness_pct = 10;
    delay_seconds = 60;
    time_condition = {
      before = "07:30:00";
      after = "20:00:00";
    };
  })

  # Motion turns the lights on at the time-of-day default only when they are
  # off, so a brightness set with the dual button holds until they next turn
  # off. timer.bathroom_lights owns turning them off.
  {
    id = "bathroom_lights";
    alias = "Bathroom lights";
    description = "Motion lighting with time-of-day defaults; the dual button adjusts brightness until the lights turn off";
    mode = "restart";
    max_exceeded = "silent";
    # An event entity being removed or re-added (integration reload, device
    # re-interview) changes state from or to None and would replay its last
    # event_type as if pressed. "unknown" stays allowed: that is the state
    # before the first press after every restart.
    condition = [
      {
        condition = "template";
        value_template = "{{ trigger.platform != 'state' or (trigger.from_state is not none and trigger.to_state is not none) }}";
      }
    ];
    variables = {
      inherit (bathroom) lights;
      default_pct = "{{ 85 if today_at('07:30') <= now() < today_at('20:00') else 10 }}";
    };
    trigger = [
      {
        platform = "state";
        entity_id = bathroom.motion;
        from = "off";
        to = "on";
        id = "motion_on";
      }
      # Not from = "on": motion going on -> unavailable -> off must still
      # start the countdown.
      {
        platform = "state";
        entity_id = bathroom.motion;
        to = "off";
        id = "motion_off";
      }
      # A timer.finished that falls due while HA is down fires during startup,
      # before this automation listens for it.
      {
        platform = "homeassistant";
        event = "start";
        id = "ha_start";
      }
      {
        platform = "event";
        event_type = "timer.finished";
        event_data.entity_id = bathroom.timer;
        id = "timer_finished";
      }
      (bathroom.buttonTrigger bathroom.buttonUp "up")
      (bathroom.buttonTrigger bathroom.buttonDown "down")
    ];
    action = [
      {
        choose = [
          {
            conditions = [
              {
                condition = "trigger";
                id = "motion_on";
              }
            ];
            sequence = [
              {
                action = "timer.cancel";
                target.entity_id = bathroom.timer;
              }
              {
                "if" = [
                  {
                    condition = "template";
                    value_template = "{{ not ${bathroom.lightsOn} }}";
                  }
                ];
                "then" = [bathroom.turnOnDefault];
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "motion_off";
              }
            ];
            sequence = [bathroom.restartTimer];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "ha_start";
              }
            ];
            sequence = [
              {
                "if" = [
                  {
                    condition = "template";
                    value_template = "{{ ${bathroom.lightsOn} }}";
                  }
                  {
                    condition = "state";
                    entity_id = bathroom.timer;
                    state = "idle";
                  }
                ];
                "then" = [bathroom.restartTimer];
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "timer_finished";
              }
            ];
            sequence = [
              {
                action = "light.turn_off";
                target.entity_id = bathroom.lights;
              }
            ];
          }
          {
            conditions = bathroom.pressed "up" "multi_press_1";
            sequence = [
              {
                "if" = [
                  {
                    condition = "template";
                    value_template = "{{ ${bathroom.lightsOn} }}";
                  }
                ];
                "then" = [(bathroom.setPct "[${bathroom.currentPct} + ${toString bathroom.stepPct}, 100] | min")];
                "else" = [bathroom.turnOnDefault];
              }
              bathroom.restartTimer
            ];
          }
          {
            conditions =
              bathroom.pressed "down" "multi_press_1"
              ++ [
                {
                  condition = "template";
                  value_template = "{{ ${bathroom.lightsOn} }}";
                }
              ];
            sequence =
              bathroom.dimTo "[${bathroom.currentPct} - ${toString bathroom.stepPct}, ${toString bathroom.floorPct}] | max"
              ++ [bathroom.restartTimer];
          }
          {
            conditions = bathroom.pressed "up" "multi_press_2";
            sequence = [
              (bathroom.setPct "100")
              bathroom.restartTimer
            ];
          }
          {
            conditions = bathroom.pressed "down" "multi_press_2";
            sequence = [
              {
                action = "light.turn_off";
                target.entity_id = bathroom.lights;
              }
              {
                action = "timer.cancel";
                target.entity_id = bathroom.timer;
              }
            ];
          }
          {
            conditions = bathroom.pressed "up" "long_press";
            sequence = [
              bathroom.restartTimer
              {
                "if" = [
                  {
                    condition = "template";
                    value_template = "{{ ${bathroom.lightsOn} }}";
                  }
                ];
                "then" = [(bathroom.ramp true)];
                "else" = [bathroom.turnOnDefault];
              }
            ];
          }
          {
            conditions =
              bathroom.pressed "down" "long_press"
              ++ [
                {
                  condition = "template";
                  value_template = "{{ ${bathroom.lightsOn} }}";
                }
              ];
            sequence = [
              bathroom.restartTimer
              (bathroom.ramp false)
            ];
          }
        ];
        # long_release lands here (its trigger has already restarted the run,
        # ending any ramp), as do down presses while the lights are off.
        default = [bathroom.restartTimer];
      }
    ];
  }

  (mkMotionLightAutomation {
    id = "living_room_lights_night";
    alias = "Living room lights (night)";
    motion_sensor = "binary_sensor.living_room_motion_sensor_occupancy";
    target.entity_id = ["light.living_room"];
    brightness_pct = 20;
    delay_seconds = 300;
    time_condition = {
      before = "01:00:00";
      after = "20:00:00";
    };
    extra_conditions = [
      {
        condition = "state";
        entity_id = "light.living_room";
        state = "off";
      }
    ];
  })

  # Away from home notifications
  {
    id = "away_notifications";
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
            entity_id = "person.darren";
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
    id = "low_battery_notifications";
    alias = "Low battery notifications";
    description = "Alert when device batteries are low";
    trigger = [
      {
        platform = "numeric_state";
        entity_id = [
          "sensor.hallway_motion_sensor_battery"
          "sensor.bathroom_motion_sensor_battery"
          "sensor.living_room_motion_sensor_battery"
          "sensor.myggbett_door_window_sensor_battery"
          "sensor.vibration_sensor_battery"
          "sensor.bathroom_temp_sensor_battery"
          "sensor.bathroom_buttons_battery"
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
    id = "ipad_low_battery";
    alias = "iPad low battery";
    trigger = [
      {
        platform = "numeric_state";
        entity_id = "sensor.lorraines_ipad_battery";
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
    id = "tv_backlight_on";
    alias = "TV Light - On";
    trigger = [
      {
        platform = "state";
        entity_id = "media_player.lg_webos_tv_49sj800v_zb";
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
        target.entity_id = "light.backlight";
        data = {
          color_temp_kelvin = 6031;
          brightness_pct = 100;
        };
      }
    ];
    mode = "single";
  }

  # TV Light - turn off when TV turns off
  {
    id = "tv_backlight_off";
    alias = "TV Lights - Off";
    trigger = [
      {
        platform = "state";
        entity_id = "media_player.lg_webos_tv_49sj800v_zb";
        to = "off";
      }
    ];
    action = [
      {
        action = "light.turn_off";
        target.entity_id = "light.backlight";
      }
    ];
    mode = "single";
  }

  # Dishwasher complete notification
  {
    id = "dishwasher_complete";
    alias = "Dishwasher complete";
    trigger = [
      {
        platform = "state";
        entity_id = "binary_sensor.vibration_sensor_vibration";
        to = "on";
      }
    ];
    action = [
      {
        wait_for_trigger = [
          {
            platform = "state";
            entity_id = "binary_sensor.vibration_sensor_vibration";
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
        action = "notify.lg_webos_tv_49sj800v_zb";
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
    id = "washing_machine_complete";
    alias = "Washing machine complete";
    trigger = [
      {
        platform = "numeric_state";
        entity_id = "sensor.washing_machine_power";
        above = 50;
      }
    ];
    action = [
      {
        wait_for_trigger = [
          {
            platform = "numeric_state";
            entity_id = "sensor.washing_machine_power";
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
        action = "notify.lg_webos_tv_49sj800v_zb";
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
    id = "auto_turn_off_tv";
    alias = "Automatically turn off TV";
    trigger = [
      {
        platform = "state";
        entity_id = "remote.living_room";
        to = "off";
      }
    ];
    action = [
      {
        action = "media_player.turn_off";
        target.entity_id = "media_player.lg_webos_tv_49sj800v_zb";
      }
    ];
    mode = "single";
  }

  # Leave Home - turn off all devices when everyone leaves
  {
    id = "leave_home";
    alias = "Leave Home";
    trigger = [
      {
        platform = "zone";
        entity_id = "person.darren";
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
            entity_id = "person.darren";
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
          "group.living_room_lights"
          "group.hallway_lights"
          "group.kitchen_lights"
          "group.bathroom_lights"
          "group.bedroom_lights"
          "group.robynne_lights"
          "light.backlight"
        ];
      }
      {
        action = "media_player.turn_off";
        target.entity_id = [
          "media_player.living_room"
          "media_player.lg_webos_tv_49sj800v_zb"
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
    id = "enter_home";
    alias = "Enter Home";
    trigger = [
      {
        platform = "zone";
        entity_id = "person.darren";
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

  # =============================================================================
  # BILRESA Living Room Control
  # 3 automations (one per button), each using choose to dispatch by trigger ID
  # =============================================================================

  # Button 1 - Living/Dining Lights (press=toggle, CW=brighter, CCW=dimmer)
  {
    id = "bilresa_button_1";
    alias = "BILRESA Button 1 - Living Room Lights";
    description = "Control living room and dining room lights";
    mode = "single";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_3";
        id = "press";
      }
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_1";
        id = "cw";
      }
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_2";
        id = "ccw";
      }
    ];
    action = [
      {
        choose = [
          {
            conditions = [
              {
                condition = "trigger";
                id = "press";
              }
              {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_1' }}";
              }
            ];
            sequence = [
              {
                action = "light.toggle";
                target.entity_id = ["light.living_room" "light.dining_room"];
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "cw";
              }
            ];
            sequence = [
              {
                action = "light.turn_on";
                target.entity_id = ["light.living_room" "light.dining_room"];
                data.brightness_step_pct = "{{ trigger.to_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "ccw";
              }
            ];
            sequence = [
              {
                action = "light.turn_on";
                target.entity_id = ["light.living_room" "light.dining_room"];
                data.brightness_step_pct = "{{ -1 * trigger.to_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
              }
            ];
          }
        ];
      }
    ];
  }

  # Button 2 - Sofa Light (press=toggle, CW=brighter, CCW=dimmer)
  {
    id = "bilresa_button_2";
    alias = "BILRESA Button 2 - Sofa Light";
    description = "Control sofa light";
    mode = "single";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_6";
        id = "press";
      }
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_4";
        id = "cw";
      }
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_5";
        id = "ccw";
      }
    ];
    action = [
      {
        choose = [
          {
            conditions = [
              {
                condition = "trigger";
                id = "press";
              }
              {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_1' }}";
              }
            ];
            sequence = [
              {
                action = "light.toggle";
                target.entity_id = "light.kajplats_e27_ws_g95_clear_806lm";
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "cw";
              }
            ];
            sequence = [
              {
                action = "light.turn_on";
                target.entity_id = "light.kajplats_e27_ws_g95_clear_806lm";
                data.brightness_step_pct = "{{ trigger.to_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "ccw";
              }
            ];
            sequence = [
              {
                action = "light.turn_on";
                target.entity_id = "light.kajplats_e27_ws_g95_clear_806lm";
                data.brightness_step_pct = "{{ -1 * trigger.to_state.attributes.totalNumberOfPressesCounted | default(1) | int * 5 }}";
              }
            ];
          }
        ];
      }
    ];
  }

  # Button 3 - TV Control
  # single press = play/pause (source-aware), double = HDMI toggle, long = power
  # CW/CCW = volume (source-aware: Apple TV on HDMI1, LG TV otherwise)
  {
    id = "bilresa_button_3";
    alias = "BILRESA Button 3 - TV Control";
    description = "Control TV: play/pause, HDMI switch, power, volume";
    mode = "single";
    trigger = [
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_9";
        id = "press";
      }
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_7";
        id = "cw";
      }
      {
        platform = "state";
        entity_id = "event.bilresa_scroll_wheel_button_8";
        id = "ccw";
      }
    ];
    action = [
      {
        choose = [
          {
            conditions = [
              {
                condition = "trigger";
                id = "press";
              }
              {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_1' }}";
              }
            ];
            sequence = [
              {
                action = "media_player.media_play_pause";
                target.entity_id = "{{ 'media_player.living_room' if state_attr('media_player.lg_webos_tv_49sj800v_zb', 'source') == 'HDMI1' else 'media_player.lg_webos_tv_49sj800v_zb' }}";
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "press";
              }
              {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.event_type == 'multi_press_2' }}";
              }
            ];
            sequence = [
              {
                action = "media_player.select_source";
                target.entity_id = "media_player.lg_webos_tv_49sj800v_zb";
                data.source = "{{ 'HDMI2' if state_attr('media_player.lg_webos_tv_49sj800v_zb', 'source') == 'HDMI1' else 'HDMI1' }}";
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "press";
              }
              {
                condition = "template";
                value_template = "{{ trigger.to_state.attributes.event_type == 'long_release' }}";
              }
            ];
            sequence = [
              {
                choose = [
                  {
                    conditions = [
                      {
                        condition = "state";
                        entity_id = "media_player.lg_webos_tv_49sj800v_zb";
                        state = "off";
                      }
                    ];
                    sequence = [
                      {
                        action = "media_player.turn_on";
                        target.entity_id = "media_player.lg_webos_tv_49sj800v_zb";
                      }
                    ];
                  }
                ];
                default = [
                  {
                    action = "media_player.turn_off";
                    target.entity_id = "media_player.lg_webos_tv_49sj800v_zb";
                  }
                ];
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "cw";
              }
            ];
            sequence = [
              {
                repeat = {
                  count = "{{ trigger.to_state.attributes.totalNumberOfPressesCounted | default(1) | int }}";
                  sequence = [
                    {
                      action = "media_player.volume_up";
                      target.entity_id = "{{ 'media_player.living_room' if state_attr('media_player.lg_webos_tv_49sj800v_zb', 'source') == 'HDMI1' else 'media_player.lg_webos_tv_49sj800v_zb' }}";
                    }
                  ];
                };
              }
            ];
          }
          {
            conditions = [
              {
                condition = "trigger";
                id = "ccw";
              }
            ];
            sequence = [
              {
                repeat = {
                  count = "{{ trigger.to_state.attributes.totalNumberOfPressesCounted | default(1) | int }}";
                  sequence = [
                    {
                      action = "media_player.volume_down";
                      target.entity_id = "{{ 'media_player.living_room' if state_attr('media_player.lg_webos_tv_49sj800v_zb', 'source') == 'HDMI1' else 'media_player.lg_webos_tv_49sj800v_zb' }}";
                    }
                  ];
                };
              }
            ];
          }
        ];
      }
    ];
  }

  # HA Backup overdue alert - fires daily at 09:00 if no backup in 2 days
  {
    id = "backup_overdue";
    alias = "HA Backup Overdue";
    description = "Alert if no successful HA backup in 2 days";
    trigger = [
      {
        platform = "time";
        at = "09:00:00";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = ''
          {% set last = states('sensor.backup_last_successful_automatic_backup') %}
          {{ last in ['unknown', 'unavailable']
             or (now() - last | as_datetime | as_local).days >= 2 }}
        '';
      }
    ];
    action = [
      {
        action = "notify.notify";
        data = {
          title = "HA Backup Overdue";
          message = "No successful Home Assistant backup in 2+ days. Check Settings → Backup.";
        };
      }
    ];
    mode = "single";
  }

  # Humidity Extractor - toggle extractor when humidity is high
  {
    id = "humidity_extractor";
    alias = "Humidity Extractor";
    trigger = [
      {
        platform = "numeric_state";
        entity_id = "sensor.bathroom_temp_sensor_humidity";
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
