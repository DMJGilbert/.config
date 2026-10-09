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

  # Room view headers: the floorplan zooms to `rooms` (the room and any zones
  # open to it) and fades the rest of the flat. Markers stand where things
  # are, `at` [x y height] cm in geometry.nix's reference frame. Lights are
  # marked on the floor or furniture under them: drawn at ceiling height,
  # they would rise up the screen into the markers behind. Tapping a light
  # toggles it; a switch or media player opens its details instead, so a
  # stray tap cannot turn it off. A marker lights up while its entity's
  # state is in `markerActive` for its kind.
  markerActive = {
    light = ["on"];
    switch = ["on"];
    media = playing;
  };
  focus.living_room = {
    rooms = ["living_room" "dining"];
    markers = [
      # Floor lamp at the window end of the sofa.
      {
        kind = "light";
        name = "Sofa";
        entity = "light.kajplats_e27_ws_g95_clear_806lm";
        at = [1055 870 0];
      }
      {
        kind = "light";
        name = "Ceiling";
        entity = "light.living_room";
        at = [884 805 0];
      }
      # Hangs over the dining table; marked on its top.
      {
        kind = "light";
        name = "Dining";
        entity = "light.dining_room";
        at = [800 554 75];
      }
      # Above the screen, clear of the plug's marker under it.
      {
        kind = "media";
        name = "TV";
        entity = "media_player.living_room_tv";
        at = [1003 634 175];
      }
      # The plug under the TV that powers the media setup.
      {
        kind = "switch";
        name = "Media";
        entity = "switch.media_switch_socket_1";
        at = [1003 650 15];
      }
    ];
  };
}
