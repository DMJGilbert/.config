# Home Assistant automations
# Extracted from default.nix for maintainability
{lib}: let
  # An entity being removed or re-added (integration reload, device
  # re-interview) changes state from or to None and would replay its last
  # state as if it had just changed.
  ignoreEntityChurn = {
    condition = "template";
    value_template = "{{ trigger.platform != 'state' or (trigger.from_state is not none and trigger.to_state is not none) }}";
  };

  # Motion lighting switched off by a restore=true timer rather than a wait
  # inside the run, so an HA restart or a sensor passing through "unavailable"
  # cannot leave the lights on. The timer also records whether this automation
  # owns the lights: paused while motion holds lights it turned on, active while
  # counting down, idle otherwise. Lights switched on by hand are never owned,
  # so they are never switched off here.
  #
  # on_conditions gate only turning the lights on; once owned, the lights are
  # held and released regardless of them. A door opening counts as motion that
  # has already cleared: it turns the lights on and starts the countdown.
  mkTimedLights = {
    id,
    alias,
    description,
    motion,
    timer,
    lights,
    brightness_pct,
    door ? null,
    on_conditions ? [],
    adopt_on_start ? false,
  }: let
    timerIs = state: {
      condition = "state";
      entity_id = timer;
      inherit state;
    };
    timerAction = action: {
      inherit action;
      target.entity_id = timer;
    };
    restartTimer = [(timerAction "timer.cancel") (timerAction "timer.start")];
    turnOn = {
      action = "light.turn_on";
      target.entity_id = lights;
      data = {inherit brightness_pct;};
    };
    whenTriggeredBy = id: sequence: {
      conditions = [
        {
          condition = "trigger";
          inherit id;
        }
      ];
      inherit sequence;
    };
  in {
    inherit id alias description;
    mode = "queued";
    max_exceeded = "silent";
    variables = {inherit lights;};
    condition = [ignoreEntityChurn];
    trigger =
      [
        {
          platform = "state";
          entity_id = motion;
          from = "off";
          to = "on";
          id = "motion_on";
        }
        # Not from = "on": motion going on -> unavailable -> off must still
        # start the countdown.
        {
          platform = "state";
          entity_id = motion;
          to = "off";
          id = "motion_off";
        }
        {
          platform = "event";
          event_type = "timer.finished";
          event_data.entity_id = timer;
          id = "timer_finished";
        }
        # A timer.finished that falls due while HA is down fires during
        # startup, before this automation listens for it.
        {
          platform = "homeassistant";
          event = "start";
          id = "ha_start";
        }
      ]
      ++ lib.optional (door != null) {
        platform = "state";
        entity_id = door;
        from = "off";
        to = "on";
        id = "door_open";
      };
    action = [
      {
        choose = [
          (whenTriggeredBy "motion_on" [
            {
              "if" = [(timerIs ["active" "paused"])];
              "then" = [(timerAction "timer.pause")];
              "else" = [
                {
                  "if" = [(timerIs "idle")] ++ on_conditions;
                  "then" = [turnOn (timerAction "timer.start") (timerAction "timer.pause")];
                }
              ];
            }
          ])
          (whenTriggeredBy "door_open" [
            {
              "if" = [(timerIs "active")];
              "then" = restartTimer;
              "else" = [
                {
                  "if" = [(timerIs "idle")] ++ on_conditions;
                  "then" = [turnOn] ++ restartTimer;
                }
              ];
            }
          ])
          (whenTriggeredBy "motion_off" [
            {
              "if" = [(timerIs "paused")];
              "then" = restartTimer;
            }
          ])
          (whenTriggeredBy "timer_finished" [
            {
              action = "light.turn_off";
              target.entity_id = lights;
            }
          ])
          (whenTriggeredBy "ha_start" (
            [
              {
                "if" = [
                  (timerIs "paused")
                  {
                    condition = "state";
                    entity_id = motion;
                    state = "off";
                  }
                ];
                "then" = restartTimer;
              }
            ]
            # A countdown that finished during startup has already gone idle,
            # losing ownership; adopting lights that are on releases them.
            ++ lib.optional adopt_on_start {
              "if" = [
                (timerIs "idle")
                {
                  condition = "template";
                  value_template = "{{ expand(lights) | selectattr('state', 'eq', 'on') | list | count > 0 }}";
                }
              ];
              "then" = restartTimer;
            }
          ))
        ];
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
  (mkTimedLights {
    id = "hallway_lights";
    alias = "Hallway lights";
    description = "Motion or the front door opening turns the hallway lights on at the time-of-day level; off 1 min after the hallway clears";
    motion = "binary_sensor.hallway_motion_sensor_occupancy";
    door = "binary_sensor.myggbett_door_window_sensor_door";
    timer = "timer.hallway_lights";
    lights = ["light.hallway" "light.door"];
    brightness_pct = "{{ 85 if today_at('07:30') <= now() < today_at('20:00') else 10 }}";
    adopt_on_start = true;
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
    # "unknown" stays allowed through buttonTrigger: that is the event
    # entities' state before the first press after every restart.
    condition = [ignoreEntityChurn];
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

  (mkTimedLights {
    id = "living_room_lights_night";
    alias = "Living room lights (night)";
    description = "Evening motion turns the living room light on at 20% if it is off; off 5 min after the room clears";
    motion = "binary_sensor.living_room_motion_sensor_occupancy";
    timer = "timer.living_room_lights";
    lights = ["light.living_room"];
    brightness_pct = 20;
    on_conditions = [
      {
        condition = "time";
        after = "20:00:00";
        before = "01:00:00";
      }
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

  # A crossing trigger alone misses a sensor that is already low, and one
  # whose battery died outright (it goes unavailable instead). The daily sweep
  # covers both; phones, tablets and watches report their own batteries.
  {
    id = "low_battery_notifications";
    alias = "Low battery notifications";
    description = "Alert on any device battery below 20% or unavailable, when it crosses and daily at 18:00";
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
      {
        platform = "time";
        at = "18:00:00";
      }
    ];
    variables.low = ''
      {% set personal = integration_entities('mobile_app') + integration_entities('icloud') + integration_entities('icloud3') %}
      {% set ns = namespace(items=[]) %}
      {% for s in states.sensor
           | selectattr('attributes.device_class', 'defined')
           | selectattr('attributes.device_class', 'eq', 'battery')
           if s.entity_id not in personal %}
        {% if s.state == 'unavailable' %}
          {% set ns.items = ns.items + [s.name ~ ': unavailable'] %}
        {% elif s.state | float(100) < 20 %}
          {% set ns.items = ns.items + [s.name ~ ': ' ~ s.state ~ '%'] %}
        {% endif %}
      {% endfor %}
      {{ ns.items }}
    '';
    condition = [
      {
        condition = "template";
        value_template = "{{ low | count > 0 }}";
      }
    ];
    action = [
      {
        action = "notify.mobile_app_hatchling";
        data = {
          title = "Low battery";
          message = "{{ low | join('\\n') }}";
          data.push.interruption-level = "time-sensitive";
        };
      }
    ];
    mode = "single";
    max_exceeded = "silent";
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

  # The 5 minute hold on the start trigger ignores brief power spikes, so only
  # a real wash cycle produces a "finished" notification.
  {
    id = "washing_machine_complete";
    alias = "Washing machine complete";
    trigger = [
      {
        platform = "numeric_state";
        entity_id = "sensor.washing_machine_power";
        above = 50;
        for.minutes = 5;
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

  # Only while the TV shows the Apple TV (HDMI1): its sleeping must not turn
  # off whatever is playing on another input.
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
    condition = [
      {
        condition = "state";
        entity_id = "media_player.lg_webos_tv_49sj800v_zb";
        attribute = "source";
        state = "HDMI1";
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
