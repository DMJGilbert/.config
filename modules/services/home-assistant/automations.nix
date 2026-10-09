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

  # Button and scroll-wheel event entities. Going unavailable and back (a
  # Thread drop, a matterjs-server restart) would otherwise replay the last
  # event as a fresh press or scroll.
  eventEntityTrigger = entity_id: id: {
    trigger = "state";
    inherit entity_id id;
    not_from = ["unavailable"];
    not_to = ["unavailable"];
  };

  # Motion lighting switched off by a restore=true timer rather than a wait
  # inside the run, so a sensor passing through "unavailable" or an HA restart
  # mid-countdown cannot leave the lights on. The timer also records whether
  # this automation owns the lights: paused while motion holds them, active
  # while counting down, idle otherwise. Motion with an idle timer takes the
  # lights over unless on_conditions refuse it — require the lights to be off
  # there to leave lights switched on by hand alone.
  #
  # on_conditions gate only taking the lights over; once owned, they are held
  # and released regardless, and turned back on if switched off meanwhile. A
  # door opening turns the lights on and starts the countdown, which holds
  # instead if motion is on.
  #
  # A sensor that stays unavailable for 10 minutes counts as the room
  # clearing, so a dead battery cannot hold the lights on indefinitely.
  #
  # A countdown that falls due while HA is down finishes during startup and
  # goes idle, releasing ownership with the lights still on. adopt_on_start
  # takes over any lights on at startup to cover that; leave it off where
  # lights switched on by hand must survive a restart.
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
    # Paths that start the countdown without a motion transition (a door
    # opening, a restart) may find the room occupied; the timer must then
    # hold rather than count down.
    restartTimerUnlessOccupied =
      restartTimer
      ++ [
        {
          "if" = [(motionIs "on")];
          "then" = [(timerAction "timer.pause")];
        }
      ];
    turnOn = {
      action = "light.turn_on";
      target.entity_id = lights;
      data = {inherit brightness_pct;};
    };
    turnOnIfAllOff = {
      "if" = [
        {
          condition = "template";
          value_template = "{{ expand(lights) | selectattr('state', 'eq', 'on') | list | count == 0 }}";
        }
      ];
      "then" = [turnOn];
    };
    motionIs = state: {
      condition = "state";
      entity_id = motion;
      inherit state;
    };
    lightsAreOn = {
      condition = "template";
      value_template = "{{ expand(lights) | selectattr('state', 'eq', 'on') | list | count > 0 }}";
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
    conditions = [ignoreEntityChurn];
    triggers =
      [
        # No from = "off": a sensor that drops out and comes back reporting
        # motion goes unavailable -> on.
        {
          trigger = "state";
          entity_id = motion;
          to = "on";
          id = "motion_on";
        }
        # Not from = "on": motion going on -> unavailable -> off must still
        # start the countdown.
        {
          trigger = "state";
          entity_id = motion;
          to = "off";
          id = "motion_off";
        }
        {
          trigger = "state";
          entity_id = motion;
          to = "unavailable";
          "for".minutes = 10;
          id = "motion_off";
        }
        {
          trigger = "event";
          event_type = "timer.finished";
          event_data.entity_id = timer;
          id = "timer_finished";
        }
        # A timer.finished that falls due while HA is down fires during
        # startup, before this automation listens for it.
        {
          trigger = "homeassistant";
          event = "start";
          id = "ha_start";
        }
      ]
      ++ lib.optional (door != null) {
        trigger = "state";
        entity_id = door;
        from = "off";
        to = "on";
        id = "door_open";
      };
    actions = [
      {
        choose =
          [
            (whenTriggeredBy "motion_on" [
              {
                "if" = [(timerIs ["active" "paused"])];
                "then" = [turnOnIfAllOff (timerAction "timer.pause")];
                "else" = [
                  {
                    "if" = [(timerIs "idle")] ++ on_conditions;
                    "then" = [turnOn (timerAction "timer.start") (timerAction "timer.pause")];
                  }
                ];
              }
            ])
          ]
          ++ lib.optional (door != null) (whenTriggeredBy "door_open" [
            {
              "if" = [(timerIs "active")];
              "then" = [turnOnIfAllOff] ++ restartTimerUnlessOccupied;
              "else" = [
                {
                  "if" = [(timerIs "idle")] ++ on_conditions;
                  "then" = [turnOn] ++ restartTimerUnlessOccupied;
                }
              ];
            }
          ])
          ++ [
            (whenTriggeredBy "motion_off" [
              {
                "if" = [(timerIs "paused")];
                # Lights switched off by hand need no countdown; cancelling
                # leaves the timer idle, so the next motion starts afresh.
                "then" = [
                  {
                    "if" = [lightsAreOn];
                    "then" = restartTimer;
                    "else" = [(timerAction "timer.cancel")];
                  }
                ];
              }
            ])
            (whenTriggeredBy "timer_finished" [
              {
                action = "light.turn_off";
                target.entity_id = lights;
              }
            ])
            # Motion may have changed while HA was down without a transition
            # to trigger on, so the restored timer is reconciled with it.
            (whenTriggeredBy "ha_start" (
              [
                {
                  # unavailable too: the 10 minute unavailable trigger's
                  # pending wait does not survive a restart.
                  "if" = [(timerIs "paused") (motionIs ["off" "unavailable"])];
                  "then" = restartTimer;
                }
                {
                  "if" = [(timerIs "active") (motionIs "on")];
                  "then" = [(timerAction "timer.pause")];
                }
              ]
              ++ lib.optional adopt_on_start {
                "if" = [(timerIs "idle") lightsAreOn];
                "then" = restartTimerUnlessOccupied;
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
    # the timer stays cancelled. An unavailable sensor counts as clear, so a
    # dead battery cannot hold the lights on. It does not check the lights are
    # on: right after light.turn_on their state may not have updated yet. The
    # motion-cleared path, where it has, checks before calling it. The cancel
    # matters: a bare timer.start on a timer restored after a restart resumes
    # its remaining time rather than the full duration.
    restartTimer = {
      "if" = [
        {
          condition = "state";
          entity_id = motion;
          state = ["off" "unavailable"];
        }
      ];
      "then" = [
        {
          action = "timer.cancel";
          target.entity_id = timer;
        }
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
    # "unknown" stays allowed through eventEntityTrigger: that is the event
    # entities' state before the first press after every restart.
    conditions = [ignoreEntityChurn];
    variables = {
      inherit (bathroom) lights;
      default_pct = "{{ 85 if today_at('07:30') <= now() < today_at('20:00') else 10 }}";
    };
    triggers = [
      # No from = "off": see mkTimedLights.
      {
        trigger = "state";
        entity_id = bathroom.motion;
        to = "on";
        id = "motion_on";
      }
      # Not from = "on": motion going on -> unavailable -> off must still
      # start the countdown.
      {
        trigger = "state";
        entity_id = bathroom.motion;
        to = "off";
        id = "motion_off";
      }
      {
        trigger = "state";
        entity_id = bathroom.motion;
        to = "unavailable";
        "for".minutes = 10;
        id = "motion_off";
      }
      # A timer.finished that falls due while HA is down fires during startup,
      # before this automation listens for it.
      {
        trigger = "homeassistant";
        event = "start";
        id = "ha_start";
      }
      {
        trigger = "event";
        event_type = "timer.finished";
        event_data.entity_id = bathroom.timer;
        id = "timer_finished";
      }
      (eventEntityTrigger bathroom.buttonUp "up")
      (eventEntityTrigger bathroom.buttonDown "down")
    ];
    actions = [
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
            # By the time motion clears the lights' state has settled, so a
            # room left dark by hand gets no countdown; cancelling leaves the
            # timer idle for the next motion.
            sequence = [
              {
                "if" = [
                  {
                    condition = "template";
                    value_template = "{{ ${bathroom.lightsOn} }}";
                  }
                ];
                "then" = [bathroom.restartTimer];
                "else" = [
                  {
                    action = "timer.cancel";
                    target.entity_id = bathroom.timer;
                  }
                ];
              }
            ];
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
              # Motion that came on while HA was down left no transition to
              # cancel the restored countdown, as motion_on would have.
              {
                "if" = [
                  {
                    condition = "state";
                    entity_id = bathroom.timer;
                    state = "active";
                  }
                  {
                    condition = "state";
                    entity_id = bathroom.motion;
                    state = "on";
                  }
                ];
                "then" = [
                  {
                    action = "timer.cancel";
                    target.entity_id = bathroom.timer;
                  }
                ];
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

  # A crossing trigger alone misses a sensor that is already low, and one
  # whose battery died outright (it goes unavailable instead). The daily sweep
  # covers both; phones, tablets and watches report their own batteries.
  {
    id = "low_battery_notifications";
    alias = "Low battery notifications";
    description = "Alert on any device battery below 20% or unavailable, when it crosses and daily at 18:00";
    triggers = [
      {
        trigger = "numeric_state";
        entity_id = [
          "sensor.hallway_motion_sensor_battery"
          "sensor.bathroom_motion_sensor_battery"
          "sensor.living_room_motion_sensor_battery"
          "sensor.myggbett_door_window_sensor_battery"
          "sensor.vibration_sensor_battery"
          "sensor.girls_room_temp_sensor_battery"
          "sensor.bathroom_bathroom_sensor_battery"
          "sensor.bathroom_buttons_battery"
        ];
        below = 20;
      }
      {
        trigger = "time";
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
    conditions = [
      # numeric_state treats unavailable -> low as crossing below, which every
      # sensor coming back after a restart would do.
      {
        condition = "template";
        value_template = "{{ trigger.platform != 'numeric_state' or trigger.from_state.state not in ['unavailable', 'unknown'] }}";
      }
      {
        condition = "template";
        value_template = "{{ low | count > 0 }}";
      }
    ];
    actions = [
      {
        action = "notify.family";
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

  # TV Light - turn on when TV turns on (evening)
  {
    id = "tv_backlight_on";
    alias = "TV Light - On";
    triggers = [
      {
        trigger = "state";
        entity_id = "media_player.lg_webos_tv_49sj800v_zb";
        to = "on";
      }
    ];
    conditions = [
      {
        condition = "time";
        after = "17:00:00";
        before = "06:00:00";
      }
    ];
    actions = [
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
    triggers = [
      {
        trigger = "state";
        entity_id = "media_player.lg_webos_tv_49sj800v_zb";
        to = "off";
      }
    ];
    actions = [
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
    triggers = [
      {
        trigger = "numeric_state";
        entity_id = "sensor.washing_machine_power";
        above = 50;
        for.minutes = 5;
      }
    ];
    actions = [
      {
        wait_for_trigger = [
          {
            trigger = "numeric_state";
            entity_id = "sensor.washing_machine_power";
            below = 50;
            for.minutes = 5;
          }
        ];
      }
      {
        action = "notify.family";
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
    triggers = [
      {
        trigger = "state";
        entity_id = "remote.living_room";
        to = "off";
      }
    ];
    conditions = [
      {
        condition = "state";
        entity_id = "media_player.lg_webos_tv_49sj800v_zb";
        attribute = "source";
        state = "HDMI1";
      }
    ];
    actions = [
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
    triggers = [
      {
        trigger = "zone";
        entity_id = "person.darren";
        zone = "zone.home";
        event = "leave";
      }
      {
        trigger = "zone";
        entity_id = "person.lorraine";
        zone = "zone.home";
        event = "leave";
      }
    ];
    conditions = [
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
    actions = [
      {
        action = "light.turn_off";
        target.entity_id = [
          "group.living_room_lights"
          "group.hallway_lights"
          "group.kitchen_lights"
          "group.bathroom_lights"
          "group.bedroom_lights"
          "group.girls_room_lights"
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
    conditions = [ignoreEntityChurn];
    triggers = [
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_3" "press")
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_1" "cw")
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_2" "ccw")
    ];
    actions = [
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
    conditions = [ignoreEntityChurn];
    triggers = [
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_6" "press")
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_4" "cw")
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_5" "ccw")
    ];
    actions = [
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
    conditions = [ignoreEntityChurn];
    triggers = [
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_9" "press")
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_7" "cw")
      (eventEntityTrigger "event.bilresa_scroll_wheel_button_8" "ccw")
    ];
    actions = [
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
    triggers = [
      {
        trigger = "time";
        at = "09:00:00";
      }
    ];
    conditions = [
      {
        condition = "template";
        value_template = ''
          {% set last = states('sensor.backup_last_successful_automatic_backup') %}
          {{ last in ['unknown', 'unavailable']
             or (now() - last | as_datetime | as_local).days >= 2 }}
        '';
      }
    ];
    actions = [
      {
        action = "notify.family";
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
    triggers = [
      {
        trigger = "numeric_state";
        entity_id = "sensor.bathroom_bathroom_sensor_humidity";
        above = 70;
      }
    ];
    actions = [
      {
        action = "switch.toggle";
        target.entity_id = "switch.fingerbot_extractor_switch";
      }
      {delay.minutes = 30;}
    ];
    mode = "single";
  }
]
