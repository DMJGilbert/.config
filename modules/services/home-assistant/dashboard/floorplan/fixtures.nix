# Home Assistant entities behind the things drawn in the flat, keyed by
# their `name` in geometry.nix.
#
# A door's pin drops onto its threshold while its contact sensor reads
# open; a device glows, with a pool of light on the floor, while its state
# is in `active`.
let
  playing = ["on" "playing" "paused" "buffering"];
in {
  doors.front = "binary_sensor.myggbett_door_window_sensor_door";

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
  };
}
