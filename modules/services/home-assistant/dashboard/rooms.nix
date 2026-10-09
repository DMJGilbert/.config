# Rooms of the YAML-mode dashboard, one view each. `path` is the view's URL
# suffix; slugs are the entity_id fragments that identify a room's devices.
{cards}:
with cards; [
  {
    name = "Living Room";
    path = "living-room";
    icon = "fp:sofa";
    image = "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&h=600&fit=crop";
    lightGroup = "group.living_room_lights";
    media = [
      (mediaAuto {
        slugs = ["living_room"];
        icon = "fp:tv";
      })
    ];
    climate = [
      (item {
        entity = "climate.dyson";
        icon = "fp:thermostat";
      })
      (item {
        entity = "fan.dyson";
        icon = "fp:fan";
        toggle = true;
      })
      (climateAuto {
        slugs = ["living_room"];
        showEmpty = false;
      })
      (heading "Sensors")
      (sensor {
        entity = "sensor.dyson_temperature";
        icon = "fp:thermometer";
        name = "Temperature";
      })
      (sensor {
        entity = "sensor.dyson_humidity";
        icon = "fp:water";
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
        icon = "fp:flash";
        name = "Media Setup";
      })
      (heading "Sensors")
      (sensor {
        entity = "sensor.dyson_pm2_5";
        icon = "fp:air";
        name = "Air Quality (PM 2.5)";
      })
      (roomSensorsAuto [
        {
          match = "*living_room*illuminance*";
          icon = "fp:brightness";
          name = "Illuminance";
        }
        {
          match = "*living_room*temperature*";
          icon = "fp:thermometer";
          name = "Temperature";
        }
        {
          match = "*living_room*humidity*";
          icon = "fp:water";
          name = "Humidity";
        }
        {
          match = "*living_room*battery*";
          icon = "fp:battery";
        }
      ])
    ];
  }

  {
    name = "Bedroom";
    path = "bedroom";
    icon = "fp:bed";
    image = "https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&h=600&fit=crop";
    lightGroup = "group.bedroom_lights";
    media = [
      (mediaAuto {
        slugs = ["bedroom"];
        icon = "fp:tv";
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
          icon = "fp:thermometer";
          name = "Temperature";
        }
        {
          match = "*bedroom*humidity*";
          icon = "fp:water";
          name = "Humidity";
        }
        {
          match = "*bedroom*illuminance*";
          icon = "fp:brightness";
          name = "Illuminance";
        }
        {
          match = "*bedroom*battery*";
          icon = "fp:battery";
        }
      ])
    ];
  }

  {
    name = "Kitchen";
    path = "kitchen";
    icon = "fp:dining";
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
          icon = "fp:thermometer";
          name = "Temperature";
        }
        {
          match = "*kitchen*humidity*";
          icon = "fp:water";
          name = "Humidity";
        }
        {
          match = "*kitchen*power*";
          icon = "fp:flash";
        }
      ])
    ];
  }

  {
    name = "Bathroom";
    path = "bathroom";
    icon = "fp:shower";
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
        icon = "fp:motion";
        name = "Bathroom Motion";
      })
      (heading "Sensors")
      (sensor {
        entity = "sensor.bathroom_bathroom_sensor_temperature";
        icon = "fp:thermometer";
        name = "Temperature";
      })
      (sensor {
        entity = "sensor.bathroom_bathroom_sensor_humidity";
        icon = "fp:water";
        name = "Humidity";
      })
      (sensor {
        entity = "sensor.bathroom_bathroom_sensor_battery";
        icon = "fp:battery";
        name = "Sensor Battery";
      })
    ];
  }

  {
    name = "Hallway";
    path = "hallway";
    icon = "fp:door";
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
          icon = "fp:brightness";
          name = "Illuminance";
        }
        {
          match = "*hallway*battery*";
          icon = "fp:battery";
        }
      ])
    ];
  }

  {
    name = "Girls' Room";
    path = "girls-room";
    icon = "fp:teddy-bear";
    image = "https://images.unsplash.com/photo-1617331721458-bd3bd3f9c7f8?w=1200&h=600&fit=crop";
    lightGroup = "group.girls_room_lights";
    media = [
      (item {
        entity = "media_player.robynnes_yoto_player";
        icon = "fp:speaker";
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
        icon = "fp:battery";
        name = "Yoto Battery";
      })
      (sensor {
        entity = "sensor.girls_room_temp_sensor_battery";
        icon = "fp:battery";
        name = "Sensor Battery";
      })
    ];
  }
]
