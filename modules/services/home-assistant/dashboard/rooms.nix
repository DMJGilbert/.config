# Rooms of the YAML-mode dashboard, one view each. `path` is the view's URL
# suffix; slugs are the entity_id fragments that identify a room's devices.
{cards}:
with cards; [
  {
    name = "Living Room";
    path = "living-room";
    icon = "mdi:sofa";
    image = "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&h=600&fit=crop";
    lightGroup = "group.living_room_lights";
    media = [
      (mediaAuto {
        slugs = ["living_room"];
        icon = "mdi:television";
      })
    ];
    climate = [
      (item {
        entity = "climate.dyson";
        icon = "mdi:thermostat";
      })
      (item {
        entity = "fan.dyson";
        icon = "mdi:fan";
        toggle = true;
      })
      (climateAuto {
        slugs = ["living_room"];
        showEmpty = false;
      })
      (heading "Sensors")
      (sensor {
        entity = "sensor.dyson_temperature";
        icon = "mdi:thermometer";
        name = "Temperature";
      })
      (sensor {
        entity = "sensor.dyson_humidity";
        icon = "mdi:water-percent";
        name = "Humidity";
      })
      (climateSensorsAuto ["living_room"])
    ];
    other = [
      (firstHeading "Motion Activity")
      (motionAuto {
        slug = "living_room";
        motionAttributes.device_class = "motion";
      })
      (heading "Power Monitoring")
      (sensor {
        entity = "sensor.media_switch_total_energy";
        icon = "mdi:flash";
        name = "Media Setup";
      })
      (heading "Sensors")
      (sensor {
        entity = "sensor.dyson_pm2_5";
        icon = "mdi:blur";
        name = "Air Quality (PM 2.5)";
      })
      (roomSensorsAuto [
        {
          match = "*living_room*illuminance*";
          icon = "mdi:brightness-6";
          name = "Illuminance";
        }
        {
          match = "*living_room*temperature*";
          icon = "mdi:thermometer";
          name = "Temperature";
        }
        {
          match = "*living_room*humidity*";
          icon = "mdi:water-percent";
          name = "Humidity";
        }
        {
          match = "*living_room*battery*";
          icon = "mdi:battery";
        }
      ])
    ];
  }

  {
    name = "Bedroom";
    path = "bedroom";
    icon = "mdi:bed";
    image = "https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&h=600&fit=crop";
    lightGroup = "group.bedroom_lights";
    media = [
      (mediaAuto {
        slugs = ["bedroom"];
        icon = "mdi:television";
      })
    ];
    climate = [
      (climateAuto {slugs = ["bedroom"];})
      (heading "Sensors")
      (climateSensorsAuto ["bedroom"])
    ];
    other = [
      (firstHeading "Motion Activity")
      (motionAuto {slug = "bedroom";})
      (heading "Sensors")
      (roomSensorsAuto [
        {
          match = "*bedroom*temperature*";
          icon = "mdi:thermometer";
          name = "Temperature";
        }
        {
          match = "*bedroom*humidity*";
          icon = "mdi:water-percent";
          name = "Humidity";
        }
        {
          match = "*bedroom*illuminance*";
          icon = "mdi:brightness-6";
          name = "Illuminance";
        }
        {
          match = "*bedroom*battery*";
          icon = "mdi:battery";
        }
      ])
    ];
  }

  {
    name = "Kitchen";
    path = "kitchen";
    icon = "mdi:silverware-fork-knife";
    image = "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=1200&h=600&fit=crop";
    lightGroup = "group.kitchen_lights";
    media = [(mediaAuto {slugs = ["kitchen"];})];
    climate = [
      (climateAuto {slugs = ["kitchen"];})
      (heading "Sensors")
      (climateSensorsAuto ["kitchen"])
    ];
    other = [
      (firstHeading "Motion Activity")
      (motionAuto {slug = "kitchen";})
      (heading "Sensors")
      (roomSensorsAuto [
        {
          match = "*kitchen*temperature*";
          icon = "mdi:thermometer";
          name = "Temperature";
        }
        {
          match = "*kitchen*humidity*";
          icon = "mdi:water-percent";
          name = "Humidity";
        }
        {
          match = "*kitchen*power*";
          icon = "mdi:flash";
        }
      ])
    ];
  }

  {
    name = "Bathroom";
    path = "bathroom";
    icon = "mdi:shower";
    image = "https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=1200&h=600&fit=crop";
    lightGroup = "group.bathroom_lights";
    media = [(mediaAuto {slugs = ["bathroom"];})];
    climate = [
      (climateAuto {slugs = ["bathroom"];})
      (heading "Sensors")
      (climateSensorsAuto ["bathroom"])
    ];
    other = [
      (firstHeading "Motion Activity")
      (item {
        entity = "binary_sensor.bathroom_motion_sensor_occupancy";
        icon = "mdi:motion-sensor";
        name = "Bathroom Motion";
      })
      (heading "Sensors")
      (sensor {
        entity = "sensor.bathroom_bathroom_sensor_temperature";
        icon = "mdi:thermometer";
        name = "Temperature";
      })
      (sensor {
        entity = "sensor.bathroom_bathroom_sensor_humidity";
        icon = "mdi:water-percent";
        name = "Humidity";
      })
      (sensor {
        entity = "sensor.bathroom_bathroom_sensor_battery";
        icon = "mdi:battery";
        name = "Sensor Battery";
      })
    ];
  }

  {
    name = "Hallway";
    path = "hallway";
    icon = "mdi:door";
    image = "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1200&h=600&fit=crop";
    lightGroup = "group.hallway_lights";
    media = [(mediaAuto {slugs = ["hallway"];})];
    climate = [
      (climateAuto {slugs = ["hallway"];})
      (heading "Sensors")
      (climateSensorsAuto ["hallway"])
    ];
    other = [
      (firstHeading "Motion Activity")
      (motionAuto {slug = "hallway";})
      (heading "Sensors")
      (roomSensorsAuto [
        {
          match = "*hallway*illuminance*";
          icon = "mdi:brightness-6";
          name = "Illuminance";
        }
        {
          match = "*hallway*battery*";
          icon = "mdi:battery";
        }
      ])
    ];
  }

  {
    name = "Girls' Room";
    path = "girls-room";
    icon = "mdi:teddy-bear";
    image = "https://images.unsplash.com/photo-1617331721458-bd3bd3f9c7f8?w=1200&h=600&fit=crop";
    lightGroup = "group.girls_room_lights";
    media = [
      (item {
        entity = "media_player.robynnes_yoto_player";
        icon = "mdi:speaker";
      })
    ];
    climate = [
      (climateAuto {slugs = ["girls_room"];})
      (heading "Sensors")
      (climateSensorsAuto ["girls_room"])
    ];
    other = [
      (firstHeading "Sensors")
      (sensor {
        entity = "sensor.robynnes_yoto_player_battery";
        icon = "mdi:battery";
        name = "Yoto Battery";
      })
      (sensor {
        entity = "sensor.girls_room_temp_sensor_battery";
        icon = "mdi:battery";
        name = "Sensor Battery";
      })
    ];
  }
]
