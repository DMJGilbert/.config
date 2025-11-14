{...}: {
  services.home-assistant.config = {
    "script ui" = "!include scripts.yaml";
    "automation ui" = "!include automations.yaml";
    "automation manual" = [
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
      {
        alias = "Hallway lights";
        description = "";
        mode = "restart";
        max_exceeded = "silent";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.hallway_motion_sensor_occupancy";
          from = "off";
          to = "on";
        };
        action = [
          {
            alias = "Turn on the light";
            service = "light.turn_on";
            target = {
              area_id = ["hallway"];
            };
            data = {
              brightness_pct = 10;
            };
          }
          {
            alias = "Wait until there is no motion from sensor";
            wait_for_trigger = {
              platform = "state";
              entity_id = "binary_sensor.hallway_motion_sensor_occupancy";
              from = "on";
              to = "off";
            };
          }
          {
            alias = "Wait for 1 minutes";
            delay = 60;
          }
          {
            alias = "Turn off the light";
            service = "light.turn_off";
            target = {
              area_id = ["hallway"];
            };
          }
        ];
      }
      {
        alias = "Bathroom lights (day)";
        description = "";
        mode = "restart";
        max_exceeded = "silent";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.motion_sensor_motion";
          from = "off";
          to = "on";
        };
        condition = [
          {
            condition = "time";
            after = "07:30:00";
            before = "20:00:00";
          }
        ];
        action = [
          {
            alias = "Turn on the light";
            service = "light.turn_on";
            target = {
              area_id = ["bathroom"];
            };
            data = {
              brightness_pct = 85;
            };
          }
          {
            alias = "Wait until there is no motion from sensor";
            wait_for_trigger = {
              platform = "state";
              entity_id = "binary_sensor.motion_sensor_motion";
              from = "on";
              to = "off";
            };
          }
          {
            alias = "Wait for 5 minutes";
            delay = 300;
          }
          {
            alias = "Turn off the light";
            service = "light.turn_off";
            target = {
              area_id = ["bathroom"];
            };
          }
        ];
      }
      {
        alias = "Bathroom lights (night)";
        description = "";
        mode = "restart";
        max_exceeded = "silent";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.motion_sensor_motion";
          from = "off";
          to = "on";
        };
        condition = [
          {
            condition = "time";
            before = "07:30:00";
            after = "20:00:00";
          }
        ];
        action = [
          {
            alias = "Turn on the light";
            service = "light.turn_on";
            target = {
              area_id = ["bathroom"];
            };
            data = {
              brightness_pct = 10;
            };
          }
          {
            alias = "Wait until there is no motion from sensor";
            wait_for_trigger = {
              platform = "state";
              entity_id = "binary_sensor.motion_sensor_motion";
              from = "on";
              to = "off";
            };
          }
          {
            alias = "Wait for 5 minutes";
            delay = 300;
          }
          {
            alias = "Turn off the light";
            service = "light.turn_off";
            target = {
              area_id = ["bathroom"];
            };
          }
        ];
      }
      {
        alias = "Fairy lights";
        description = "";
        mode = "restart";
        max_exceeded = "silent";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.aarlo_motion_nursery";
          from = "off";
          to = "on";
        };
        condition = [
          {
            condition = "time";
            after = "20:00:00";
            before = "23:59:00";
          }
        ];
        action = [
          {
            alias = "Turn on the light";
            service = "switch.turn_on";
            target = {
              entity_id = ["switch.fairy_lights_switch"];
            };
          }
          {
            alias = "Wait until there is no motion from sensor";
            wait_for_trigger = {
              platform = "state";
              entity_id = "binary_sensor.aarlo_motion_nursery";
              from = "on";
              to = "off";
            };
          }
          {
            alias = "Wait for 10 minutes";
            delay = 600;
          }
          {
            alias = "Turn off the light";
            service = "switch.turn_off";
            target = {
              entity_id = ["switch.fairy_lights_switch"];
            };
          }
        ];
      }
      {
        alias = "Bedroom lights (night)";
        description = "";
        mode = "restart";
        max_exceeded = "silent";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.bedroom_motion_sensor_occupancy";
          from = "off";
          to = "on";
        };
        condition = [
          {
            condition = "time";
            before = "01:00:00";
            after = "20:00:00";
          }
          {
            condition = "state";
            entity_id = "light.bedroom_light_2";
            state = "off";
          }
        ];
        action = [
          {
            alias = "Turn on the light";
            service = "light.turn_on";
            target = {
              entity_id = ["light.bedroom_light_2"];
            };
            data = {
              brightness_pct = 5;
            };
          }
          {
            alias = "Wait until there is no motion from sensor";
            wait_for_trigger = {
              platform = "state";
              entity_id = "binary_sensor.bedroom_motion_sensor_occupancy";
              from = "on";
              to = "off";
            };
          }
          {
            alias = "Wait for 5 minutes";
            delay = 300;
          }
          {
            alias = "Turn off the light";
            service = "light.turn_off";
            target = {
              entity_id = ["light.bedroom_light_2"];
            };
          }
        ];
      }
      {
        alias = "Living room lights (night)";
        description = "";
        mode = "restart";
        max_exceeded = "silent";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.living_room_motion_sensor_occupancy";
          from = "off";
          to = "on";
        };
        condition = [
          {
            condition = "time";
            before = "01:00:00";
            after = "20:00:00";
          }
          {
            condition = "state";
            entity_id = "light.living_room_light";
            state = "off";
          }
        ];
        action = [
          {
            alias = "Turn on the light";
            service = "light.turn_on";
            target = {
              entity_id = ["light.living_room_light"];
            };
            data = {
              brightness_pct = 20;
            };
          }
          {
            alias = "Wait until there is no motion from sensor";
            wait_for_trigger = {
              platform = "state";
              entity_id = "binary_sensor.living_room_motion_sensor_occupancy";
              from = "on";
              to = "off";
            };
          }
          {
            alias = "Wait for 5 minutes";
            delay = 300;
          }
          {
            alias = "Turn off the light";
            service = "light.turn_off";
            target = {
              entity_id = ["light.living_room_light"];
            };
          }
        ];
      }
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
