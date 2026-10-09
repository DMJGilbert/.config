# Home Assistant entities behind the things drawn in the flat, keyed by
# their `name` in geometry.nix.
#
# A door's pin drops onto its threshold while its contact sensor reads
# open; a device glows, with a pool of light on the floor, while its state
# is in `active`, or for a numeric sensor while it reads `above` a value.
let
  playing = ["on" "playing" "paused" "buffering"];
in {
  doors.front = "binary_sensor.myggbett_door_window_sensor_door";

  # Badges for who's home, in seat order (geometry.nix seats): on the sofa
  # while home, in bed while `bedtime` is on, outside the front door while
  # away.
  people = [
    {
      name = "darren";
      entity = "person.darren";
      initial = "D";
    }
    {
      name = "lorraine";
      entity = "person.lorraine";
      initial = "L";
    }
  ];
  bedtime = "binary_sensor.bedtime";

  # Windows glow with daylight while the sun is up.
  daylight = "sun.sun";

  # Rain falls over the outdoor room `area` while the forecast reports it.
  rain = {
    entity = "weather.forecast_home";
    area = "balcony";
    states = ["rainy" "pouring" "lightning-rainy"];
  };

  devices = {
    bedroom_tv = {
      entity = "media_player.bedroom_tv";
      active = playing;
    };
    living_room_tv = {
      entity = "media_player.living_room_tv";
      active = playing;
    };
    yoto = {
      entity = "media_player.robynnes_yoto_player";
      active = playing;
    };
    # Glows warm while heating, cool otherwise, from its climate entity.
    dyson = {
      entity = "fan.dyson";
      active = ["on"];
      mode = "climate.dyson";
    };
    # Running while the plug draws more than standby power.
    washing_machine = {
      entity = "sensor.washing_machine_power";
      above = 5;
    };
    # The Fingerbot presses the extractor's switch.
    extractor = {
      entity = "switch.fingerbot_extractor_switch";
      active = ["on"];
    };
    robovac = {
      entity = "vacuum.robovac";
      active = ["cleaning" "returning"];
    };
  };
}
