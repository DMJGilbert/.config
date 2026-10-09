# Isometric floorplan card: the drawings and stylesheet are built from
# geometry.nix and tiles.nix, and the ha-floorplan rules that animate them
# are generated from the same tiles, so element ids cannot drift apart.
#
# `files` is served at `baseUrl`; `card` is the Lovelace card config and
# `popups` the pop-ups its tiles open. `viewPaths` are the room views that
# exist, to catch a tile linking nowhere; `cards` are the room views' card
# builders, so pop-ups list lights the way the room views do.
{
  lib,
  pkgs,
  cards,
  viewPaths,
  baseUrl ? "/local/floorplan",
}: let
  geometry = import ./geometry.nix;
  tiles = import ./tiles.nix;
  fixtures = import ./fixtures.nix;

  doorNames = map (o: o.name) (lib.filter (o: o.type == "door" && o ? name) geometry.openings);
  doorRules =
    lib.mapAttrsToList (
      name: entity:
        assert lib.assertMsg (lib.elem name doorNames) "floorplan fixtures: no door named `${name}` in geometry.nix"; {
          inherit entity;
          element = "door.${name}";
          state_action = markOn ["door.${name}"] ["on"];
        }
    )
    fixtures.doors;

  deviceNames = map (d: d.name) geometry.devices;
  deviceRules =
    lib.mapAttrsToList (
      name: device:
        assert lib.assertMsg (lib.elem name deviceNames) "floorplan fixtures: no device named `${name}` in geometry.nix"; {
          inherit (device) entity;
          element = "device.${name}";
          state_action =
            markWhen ["device.${name}" "device.${name}.glow"]
            (
              if device ? above
              then activeAbove device.above
              else activeWhen device.active
            );
        }
    )
    fixtures.devices;

  roomIds = map (r: r.id) geometry.rooms;
  checked =
    lib.mapAttrs (
      id: room:
        assert lib.assertMsg (lib.elem id roomIds) "floorplan tiles: no room `${id}` in geometry.nix";
        assert lib.assertMsg (lib.elem room.view viewPaths) "floorplan tiles: ${id} links to missing view `${room.view}`";
        assert lib.assertMsg (room.tiles != []) "floorplan tiles: ${id} has no tiles; drop the room instead"; room
    )
    tiles;

  json = name: value: pkgs.writeText name (builtins.toJSON value);
  python = pkgs.python3.withPackages (ps: [ps.shapely]);

  files = pkgs.runCommand "hass-floorplan" {nativeBuildInputs = [python];} ''
    mkdir $out
    for layout in landscape portrait; do
      python ${./render.py} ${json "geometry.json" geometry} "$out/$layout.svg" \
        --tiles ${json "tiles.json" checked} --layout "$layout" \
        --people ${json "people.json" fixtures.people}
    done
    cp ${./floorplan.css} $out/floorplan.css
  '';

  # /local is served with a long max-age; the store hash changes the URL
  # exactly when the files change.
  url = file: "${baseUrl}/${file}?v=${builtins.substring 11 8 "${files}"}";

  # ha-floorplan evaluates these in a sandboxed interpreter, so they keep to
  # plain expressions.
  activeWhen = states: "\${${builtins.toJSON states}.includes(entity.state) ? \"1\" : \"0\"}";
  activeAbove = limit: "\${parseFloat(entity.state) > ${toString limit} ? \"1\" : \"0\"}";
  labelText = tile: ''> return ${builtins.toJSON tile.labels}[entity.state] || "–";'';

  # Comfort bands for the readings by each room's name; outside them the
  # reading is coloured (floorplan.css).
  comfort = {
    temperature = {
      below = 18;
      low = "cold";
      above = 23;
      high = "warm";
      text = ''> const v = parseFloat(entity.state); return isNaN(v) ? "–" : v.toFixed(1) + "°";'';
    };
    humidity = {
      below = 40;
      low = "dry";
      above = 60;
      high = "damp";
      text = ''> const v = parseFloat(entity.state); return isNaN(v) ? "–" : v.toFixed(0) + "%";'';
    };
  };

  climateRules = id: room: let
    reading = kind: element: let
      band = comfort.${kind};
    in {
      entity = room.climate.${kind};
      inherit element;
      state_action = [
        {
          service = "floorplan.text_set";
          service_data.text = band.text;
        }
        {
          service = "floorplan.dataset_set";
          service_data = {
            key = "level";
            value = "\${parseFloat(entity.state) < ${toString band.below} ? \"${band.low}\" : parseFloat(entity.state) > ${toString band.above} ? \"${band.high}\" : \"ok\"}";
          };
        }
      ];
    };
  in
    lib.optionals (room ? climate) [
      (reading "temperature" "${id}.temp")
      (reading "humidity" "${id}.humidity")
    ];

  datasetSet = key: elements: value: {
    service = "floorplan.dataset_set";
    service_data = {inherit elements key value;};
  };
  markWhen = datasetSet "on";
  markOn = elements: states: markWhen elements (activeWhen states);

  popupHash = id: kind: "#floorplan-${id}-${kind}";

  # One bubble-card pop-up per room and kind of tile it has: the room's
  # lights with their toggles, or controls for each of its media players.
  popupContent = {
    lights = room:
      if lib.hasPrefix "group." room.lights
      then [
        (cards.auto {
          include = [
            {
              group = room.lights;
              options = cards.item {
                entity = "this.entity_id";
                icon = "mdi:lightbulb";
                toggle = true;
              };
            }
          ];
          exclude = [
            {entity_id = "*coordinator*";}
            {state = "unavailable";}
          ];
          showEmpty = true;
        })
      ]
      else [
        (cards.item {
          entity = room.lights;
          icon = "mdi:lightbulb";
          toggle = true;
        })
      ];
    media = room:
      map (tile: {
        type = "media-control";
        inherit (tile) entity;
      }) (lib.filter (tile: tile.popup == "media") room.tiles);
  };
  popupTitle = {
    lights = name: "${name} Lights";
    media = name: "${name} Media";
  };
  popupIcon = {
    lights = "mdi:lightbulb";
    media = "mdi:television";
  };
  roomName = id: (lib.findFirst (r: r.id == id) null geometry.rooms).name;

  roomPopups = id: room:
    map (kind: {
      type = "custom:bubble-card";
      card_type = "pop-up";
      hash = popupHash id kind;
      name = popupTitle.${kind} (roomName id);
      icon = popupIcon.${kind};
      styles = ''
        .bubble-pop-up-container {
          background: var(--card-background-color);
        }
      '';
      cards = popupContent.${kind} room;
    }) (lib.unique (map (tile: tile.popup) room.tiles));

  roomRules = id: room: let
    navigate = {
      action = "navigate";
      navigation_path = "/lovelace-home/room-${room.view}";
    };
    tileRule = k: tile: let
      element = "${id}.tile${toString k}";
      openPopup = {
        action = "navigate";
        navigation_path = popupHash id tile.popup;
      };
    in {
      inherit (tile) entity;
      # Taps and holds bind to the tile's hit rect, which has no children, so
      # each fires once; render.py explains why.
      element = "${element}.hit";
      tap_action =
        if tile.toggle or false
        then {
          action = "call-service";
          # homeassistant.toggle expands a group and toggles each member, so
          # a room with some lights on would swap which ones are lit. Switch
          # the whole group by its own state instead.
          service = "\${entity.state === \"on\" ? \"homeassistant.turn_off\" : \"homeassistant.turn_on\"}";
          service_data.entity_id = tile.entity;
        }
        else openPopup;
      hold_action = openPopup;
      state_action = [
        (markOn [element] tile.active)
        {
          service = "floorplan.text_set";
          service_data = {
            element = "${element}.text";
            text = labelText tile;
          };
        }
      ];
    };
  in
    [
      {
        entity = room.lights;
        element = "${id}.floor";
        tap_action = navigate;
        state_action = markOn (map (part: "${id}.${part}") ["floor" "leader" "anchor" "strip"]) ["on"];
      }
      {
        element = "${id}.title";
        tap_action = navigate;
      }
    ]
    ++ lib.imap0 tileRule room.tiles
    ++ climateRules id room
    ++ lib.optional (room ? motion) {
      entity = room.motion;
      element = "${id}.motion";
      state_action = markOn ["${id}.motion"] ["on"];
    }
    ++ lib.optional (room ? timer) {
      entity = room.timer;
      element = "${id}.countdown";
      state_action = [
        {
          service = "floorplan.style_set";
          service_data.style = countdownStyle;
        }
        (datasetSet "run" ["${id}.countdown"] countdownRun)
      ];
    };

  # A timer only reports when it starts, pauses, restarts or ends, so the
  # ring drains by a CSS animation: these give it the timer's length and
  # the seconds left (attributes duration, finishes_at, remaining).
  countdownStyle = ''
    > const hms = function (s) { const p = String(s || "0:0:0").split(":"); return p[0] * 3600 + p[1] * 60 + p[2] * 1; };
    const a = entity.attributes || {};
    const total = hms(a.duration) || 1;
    let left = total;
    if (entity.state === "active") { left = (Date.parse(a.finishes_at) - Date.now()) / 1000 || 0; }
    if (entity.state === "paused") { left = hms(a.remaining); }
    return "--fp-total: " + total + "; --fp-left: " + Math.max(0, Math.min(total, left));
  '';
  # A restarted timer must restart the animation, which only happens when
  # the animation's name changes: alternate between two identical ones.
  countdownRun = "\${entity.state === \"active\" ? (element.dataset.run === \"a\" ? \"b\" : \"a\") : entity.state === \"paused\" ? \"paused\" : \"off\"}";

  personRules =
    map (person: {
      inherit (person) entity;
      element = person.entity;
      state_action = markOn [person.entity] ["home"];
    })
    fixtures.people
    ++ [
      {
        entity = fixtures.bedtime;
        element = (lib.head fixtures.people).entity;
        state_action = datasetSet "bedtime" (map (p: p.entity) fixtures.people) (activeWhen ["on"]);
      }
    ];
in {
  inherit files;
  # The pop-ups open on top of whatever tab is showing, so they live with
  # the home view's other pop-ups rather than inside the floorplan tab.
  popups = {
    type = "vertical-stack";
    cards = lib.concatLists (lib.mapAttrsToList roomPopups checked);
  };
  card = {
    type = "custom:floorplan-card";
    # The drawing sits on the page; floorplan.css paints its hidden-line
    # fills in the page background to match.
    card_mod.style = ''
      ha-card {
        background: none;
        border: none;
        box-shadow: none;
      }
    '';
    config = {
      image.sizes = [
        {
          min_width = 0;
          location = url "portrait.svg";
          cache = true;
        }
        {
          min_width = 768;
          location = url "landscape.svg";
          cache = true;
        }
      ];
      stylesheet = url "floorplan.css";
      rules = lib.concatLists (lib.mapAttrsToList roomRules checked) ++ doorRules ++ deviceRules ++ personRules;
    };
  };
}
