# Floor geometry of the flat, in centimetres, for the isometric floorplan.
#
# Measurements come from a dimensioned plan of a neighbouring flat in the
# same block (identical shell, ~120 px per metre on that drawing). That plan
# is the reference frame: x grows right, y grows down. Ours differs inside:
# there is no en suite (its space is part of the bedroom), and the open-plan
# kitchen/living/dining is split into the zones the robot vacuum's map uses.
# `rotate` turns the reference frame into the orientation the household knows
# from the vacuum map and the 3D render.
#
# Rooms are inner floor polygons. The renderer derives solid walls from them:
# the gaps between neighbouring rooms (a wall thickness apart) are filled,
# an exterior wall is added around the outside, and `openings` cut doors or
# remove walls between open-plan zones. Outdoor rooms get a railing instead.
{
  rotate = 90; # degrees anticlockwise, reference frame -> display

  rooms = [
    {
      id = "girls_room";
      name = "Girls' Room";
      polygon = [[100 110] [469 110] [469 479] [100 479]];
    }
    # One straight wall separates it from the girls' room down to the
    # hallway, in line with the kitchen's wall; the neighbour's en suite
    # corner is part of this room.
    {
      id = "bedroom";
      name = "Bedroom";
      polygon = [[479 110] [938 110] [938 419] [660 419] [610 469] [610 549] [479 549]];
    }
    {
      id = "storage";
      name = "Storage";
      polygon = [[100 490] [229 490] [229 599] [100 599]];
    }
    {
      id = "hallway";
      name = "Hallway";
      polygon = [[240 490] [469 490] [469 559] [609 559] [609 669] [469 669] [469 789] [240 789]];
    }
    {
      id = "bathroom";
      name = "Bathroom";
      polygon = [[250 800] [469 800] [469 979] [250 979]];
    }
    # The 45° corner runs parallel to the bedroom's, a wall thickness away.
    {
      id = "dining";
      name = "Dining";
      polygon = [[663 430] [938 430] [938 679] [619 679] [619 474]];
    }
    {
      id = "kitchen";
      name = "Kitchen";
      polygon = [[479 679] [689 679] [689 979] [479 979]];
    }
    {
      id = "living_room";
      name = "Living Room";
      polygon = [[689 679] [938 679] [938 631] [1079 631] [1079 979] [689 979]];
    }
    # Reached through the bedroom's glazed door; no walls, only a railing.
    {
      id = "balcony";
      name = "Balcony";
      outdoor = true;
      polygon = [[979 75] [1112 75] [1112 588] [979 588]];
    }
  ];

  # Simple boxes [x0 y0 x1 y1] with a height, placed from the household's
  # 3D render and the neighbour's plan (hob and sink positions).
  furniture = [
    # UK king (5 ft) with frame, headboard on the wall shared with dining.
    {
      name = "bed";
      rect = [719 209 879 419];
      height = 50;
    }
    # UK double with frame, headboard on the exterior wall between the windows.
    {
      name = "girls-bed";
      rect = [194 110 334 310];
      height = 50;
    }
    {
      name = "sofa";
      rect = [839 890 1039 979];
      height = 80;
    }
    {
      name = "dining-table";
      rect = [760 484 840 624];
      height = 75;
    }
    {
      name = "worktop-hob";
      rect = [479 710 539 979];
      height = 90;
    }
    {
      name = "worktop-sink";
      rect = [539 919 659 979];
      height = 90;
    }
    {
      name = "bath";
      rect = [250 812 320 979];
      height = 55;
    }
    {
      name = "toilet";
      rect = [405 920 455 979];
      height = 40;
    }
    {
      name = "basin";
      rect = [329 945 389 979];
      height = 85;
    }
    # Beside the girls' bed; the Yoto sits on it.
    {
      name = "girls-cabinet";
      rect = [110 245 180 315];
      height = 45;
    }
  ];

  # Media players drawn in the flat, boxes like furniture raised to `base`
  # cm. Their entities are in fixtures.nix; they light up while playing.
  devices = [
    # On the window wall, facing the bed.
    {
      name = "bedroom_tv";
      rect = [810 110 930 116];
      base = 60;
      height = 68;
    }
    # On the back wall of the living room's bay, facing the sofa.
    {
      name = "living_room_tv";
      rect = [943 631 1063 637];
      base = 55;
      height = 68;
    }
    {
      name = "yoto";
      rect = [134 268 156 292];
      base = 45;
      height = 20;
    }
  ];

  # Segments along room edges. `open` removes the wall (open-plan zones),
  # `door` cuts a full-height gap, `window` marks glazing in the wall.
  openings = [
    # Open plan: kitchen | living, and dining over both.
    {
      type = "open";
      from = [689 679];
      to = [689 979];
    }
    {
      type = "open";
      from = [619 679];
      to = [938 679];
    }
    {
      type = "open";
      from = [938 631];
      to = [938 679];
    }

    {
      type = "door";
      name = "front";
      from = [240 690];
      to = [240 779];
    }
    {
      type = "door";
      from = [260 479];
      to = [359 479];
    }
    {
      type = "door";
      from = [260 490];
      to = [359 490];
    }
    {
      type = "door";
      from = [229 500];
      to = [229 583];
    }
    {
      type = "door";
      from = [240 500];
      to = [240 583];
    }
    {
      type = "door";
      from = [520 549];
      to = [609 549];
    }
    {
      type = "door";
      from = [520 559];
      to = [609 559];
    }
    {
      type = "door";
      from = [609 560];
      to = [609 660];
    }
    {
      type = "door";
      from = [619 560];
      to = [619 660];
    }
    {
      type = "door";
      from = [370 789];
      to = [450 789];
    }
    {
      type = "door";
      from = [370 800];
      to = [450 800];
    }
    # Glazed door on the balcony side.
    {
      type = "door";
      from = [938 180];
      to = [938 309];
    }
    {
      type = "window";
      from = [1079 740];
      to = [1079 870];
    }

    {
      type = "window";
      from = [100 110];
      to = [189 110];
    }
    {
      type = "window";
      from = [340 110];
      to = [429 110];
    }
    {
      type = "window";
      from = [620 110];
      to = [719 110];
    }
    {
      type = "window";
      from = [938 430];
      to = [938 520];
    }
  ];
}
