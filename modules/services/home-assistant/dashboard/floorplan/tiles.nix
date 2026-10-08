# Tile strips of the floorplan, keyed by the room ids in geometry.nix.
#
# `lights` is the entity whose state lights the room: its floor glows and
# the leader line from its strip lights up. `view` is the room view that a
# tap on the floor or the room's name opens. Each tile is a light or media
# player drawn as an icon with its state below. Holding it opens the room's
# `popup` of that kind, listing the room's lights or controlling its media;
# tapping it toggles the entity if `toggle` is set, otherwise also opens the
# pop-up. Rooms with `climate` sensors show their temperature and humidity
# next to their name.
let
  climate = prefix: {
    temperature = "sensor.${prefix}_temperature";
    humidity = "sensor.${prefix}_humidity";
  };

  onOff = {
    on = "On";
    off = "Off";
  };

  light = entity: {
    inherit entity;
    icon = "lightbulb-group";
    toggle = true;
    popup = "lights";
    active = ["on"];
    labels = onOff;
  };
  media = icon: entity: {
    inherit entity icon;
    popup = "media";
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
in {
  living_room = {
    view = "living-room";
    lights = "group.living_room_lights";
    climate = climate "dyson";
    tiles = [
      (light "group.living_room_lights")
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
    climate = climate "bathroom_bathroom_sensor";
    tiles = [(light "group.bathroom_lights")];
  };
  hallway = {
    view = "hallway";
    lights = "group.hallway_lights";
    climate = climate "hallway_temp_sensor";
    tiles = [(light "group.hallway_lights")];
  };
  bedroom = {
    view = "bedroom";
    lights = "group.bedroom_lights";
    climate = climate "alpstuga_air_quality_monitor";
    tiles = [
      (light "group.bedroom_lights")
      (media "television" "media_player.bedroom_tv")
    ];
  };
  girls_room = {
    view = "girls-room";
    lights = "group.girls_room_lights";
    climate = climate "girls_room_temp_sensor";
    tiles = [
      (light "group.girls_room_lights")
      (media "speaker" "media_player.robynnes_yoto_player")
    ];
  };
}
