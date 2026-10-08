# Tile strips of the floorplan, keyed by the room ids in geometry.nix.
#
# `lights` is the entity whose state lights the room: its floor glows and
# the leader line from its strip lights up. `view` is the room view a tap
# opens. Each tile is an entity drawn as an icon with its state below.
let
  onOff = {
    on = "On";
    off = "Off";
  };

  light = entity: {
    inherit entity;
    icon = "lightbulb-group";
    active = ["on"];
    labels = onOff;
  };
  motion = entity: {
    inherit entity;
    icon = "motion-sensor";
    active = ["on"];
    labels = {
      on = "Motion";
      off = "Clear";
    };
  };
  door = entity: {
    inherit entity;
    icon = "door";
    active = ["on"];
    labels = {
      on = "Open";
      off = "Closed";
    };
  };
  media = icon: entity: {
    inherit entity icon;
    active = ["on" "playing" "paused" "buffering"];
    labels = {
      on = "On";
      off = "Off";
      standby = "Off";
      idle = "Idle";
      playing = "Playing";
      paused = "Paused";
      buffering = "Loading";
    };
  };
  humidity = entity: {
    inherit entity;
    icon = "water-percent";
    unit = "%";
    digits = 0;
  };
in {
  living_room = {
    view = "living-room";
    lights = "group.living_room_lights";
    tiles = [
      (light "group.living_room_lights")
      (motion "binary_sensor.living_room_motion_sensor_occupancy")
      (media "television" "media_player.living_room_tv")
    ];
  };
  # Dining shares the living room's view; its light is in that group too.
  dining = {
    view = "living-room";
    lights = "light.dining_room";
    tiles = [(light "light.dining_room")];
  };
  kitchen = {
    view = "kitchen";
    lights = "group.kitchen_lights";
    tiles = [(light "group.kitchen_lights")];
  };
  bathroom = {
    view = "bathroom";
    lights = "group.bathroom_lights";
    tiles = [
      (light "group.bathroom_lights")
      (humidity "sensor.bathroom_temp_sensor_humidity")
      (motion "binary_sensor.bathroom_motion_sensor_occupancy")
    ];
  };
  hallway = {
    view = "hallway";
    lights = "group.hallway_lights";
    tiles = [
      (light "group.hallway_lights")
      (motion "binary_sensor.hallway_motion_sensor_occupancy")
      (door "binary_sensor.myggbett_door_window_sensor_door")
    ];
  };
  bedroom = {
    view = "bedroom";
    lights = "group.bedroom_lights";
    tiles = [
      (light "group.bedroom_lights")
      (media "television" "media_player.bedroom_tv")
    ];
  };
  girls_room = {
    view = "girls-room";
    lights = "group.girls_room_lights";
    tiles = [
      (light "group.girls_room_lights")
      (media "speaker" "media_player.robynnes_yoto_player")
    ];
  };
}
