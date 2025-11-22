{lib, ...}: let
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
in {
  services.home-assistant.config = {
    "script ui" = "!include scripts.yaml";
    "automation ui" = "!include automations.yaml";
    "automation manual" = [
      # Living Room light dimmer (blueprint-based, not using helper)
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
    ];
  };
}
