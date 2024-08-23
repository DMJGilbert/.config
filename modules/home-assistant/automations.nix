{...}: {
  services.home-assistant.config.automation = [
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
            brightness_pct = 100;
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
  ];
}
