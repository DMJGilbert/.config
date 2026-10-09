# Isometric floorplan cards: the drawings and stylesheet are built from
# geometry.nix, tiles.nix and fixtures.nix, and the ha-floorplan rules that
# animate them are generated from the same data, so element ids cannot drift
# apart.
#
# `files` is served at `baseUrl`. `homeCard` is the whole flat, for the home
# view's header. `roomHeaders.<view path>` is the header of each room view
# with a `focus` in fixtures.nix: its `card`, and the room's `climate` and
# `motion` entities where tiles.nix has them, for the tiles laid over it.
# `thumbnails.<room>` is the URL of each room's thumbnail. `viewPaths` are
# the room views that exist, to catch a room linking nowhere.
{
  lib,
  pkgs,
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
  deviceRules = lib.concatLists (lib.mapAttrsToList (
      name: device: let
        parts = ["device.${name}" "device.${name}.glow"];
      in
        assert lib.assertMsg (lib.elem name deviceNames) "floorplan fixtures: no device named `${name}` in geometry.nix";
          [
            {
              inherit (device) entity;
              element = "device.${name}";
              state_action =
                markWhen parts
                (
                  if device ? above
                  then activeAbove device.above
                  else activeWhen device.active
                );
            }
          ]
          # A climate entity's mode colours the device: data-mode heat or cool.
          ++ lib.optional (device ? mode) {
            entity = device.mode;
            element = "device.${name}.glow";
            state_action = datasetSet "mode" parts "\${entity.state === \"heat\" ? \"heat\" : \"cool\"}";
          }
    )
    fixtures.devices);

  roomIds = map (r: r.id) geometry.rooms;
  checked =
    lib.mapAttrs (
      id: room:
        assert lib.assertMsg (lib.elem id roomIds) "floorplan tiles: no room `${id}` in geometry.nix";
        assert lib.assertMsg (lib.elem room.view viewPaths) "floorplan tiles: ${id} links to missing view `${room.view}`";
        assert lib.assertMsg (room.tiles != []) "floorplan tiles: ${id} has no tiles; drop the room instead"; room
    )
    tiles;

  markerKinds = lib.attrNames fixtures.markerActive;
  # Headers are keyed by view, and rooms can share one (dining opens the
  # living room's), so two foci on one view would leave only one header.
  focusViews = map (id: checked.${id}.view or id) (lib.attrNames fixtures.focus);
  focus = assert lib.assertMsg (lib.allUnique focusViews) "floorplan focus: two rooms with a focus open the same view; give the view one focus listing both rooms";
    lib.mapAttrs (
      id: spec:
        assert lib.assertMsg (checked ? ${id}) "floorplan focus: ${id} has no room view in tiles.nix";
        assert lib.assertMsg (lib.all (m: lib.elem m.kind markerKinds) spec.markers) "floorplan focus: ${id} has a marker kind not in markerActive"; spec
    )
    fixtures.focus;

  json = name: value: pkgs.writeText name (builtins.toJSON value);
  python = pkgs.python3.withPackages (ps: [ps.shapely]);

  # Room headers are cropped taller on phones than on wider screens, whose
  # cards are wide and short.
  headerAspects = {
    portrait = 1.1;
    landscape = 2.4;
  };

  files = pkgs.runCommand "hass-floorplan" {nativeBuildInputs = [python];} ''
    mkdir $out
    render() {
      python ${./render.py} ${json "geometry.json" geometry} "$@" --layout scene \
        --tiles ${json "tiles.json" checked} \
        --people ${json "people.json" fixtures.people}
    }
    render $out/scene.svg
    ${lib.concatStrings (lib.mapAttrsToList (id: spec:
      lib.concatStrings (lib.mapAttrsToList (layout: aspect: ''
          render $out/focus-${id}-${layout}.svg --focus ${json "focus-${id}.json" spec} --aspect ${toString aspect}
        '')
        headerAspects))
    focus)}
    # Thumbnails are shown as images, so they carry their stylesheet.
    cat ${./floorplan.css} ${./thumbnail.css} > thumbnail-style.css
    ${lib.concatMapStrings (id: ''
      render $out/thumb-${id}.svg --thumb ${id} --style thumbnail-style.css
    '') (lib.attrNames checked)}
    cp ${./floorplan.css} $out/floorplan.css
  '';

  # /local is served with a long max-age; the store hash changes the URL
  # exactly when the files change.
  url = file: "${baseUrl}/${file}?v=${builtins.substring 11 8 "${files}"}";

  # ha-floorplan evaluates these in a sandboxed interpreter, so they keep to
  # plain expressions.
  activeWhen = states: "\${${builtins.toJSON states}.includes(entity.state) ? \"1\" : \"0\"}";
  activeAbove = limit: "\${parseFloat(entity.state) > ${toString limit} ? \"1\" : \"0\"}";

  datasetSet = key: elements: value: {
    service = "floorplan.dataset_set";
    service_data = {inherit elements key value;};
  };
  markWhen = datasetSet "on";
  markOn = elements: states: markWhen elements (activeWhen states);

  roomRules = id: room:
    [
      {
        entity = room.lights;
        element = "${id}.floor";
        tap_action = {
          action = "navigate";
          navigation_path = "/lovelace-home/room-${room.view}";
        };
        # The countdown ring shows only while lit: the timer also runs after
        # the lights have been switched off by hand.
        state_action =
          markOn
          (map (part: "${id}.${part}") (["floor"] ++ lib.optional (room ? timer) "countdown"))
          ["on"];
      }
    ]
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

  # A marker's state line: a light's brightness, otherwise the state itself.
  markerText = {
    light = ''> if (entity.state !== "on") return entity.state === "off" ? "Off" : "Unavailable"; const b = (entity.attributes || {}).brightness; return b ? Math.round(b / 2.55) + "%" : "On";'';
    switch = ''> return { on: "On", off: "Off" }[entity.state] || "Unavailable";'';
    media = ''> const s = String(entity.state); return s.charAt(0).toUpperCase() + s.slice(1);'';
  };
  markerRule = marker: let
    element = "marker.${marker.entity}";
  in {
    inherit (marker) entity;
    # Bound to the marker's hit disc, which has no children, so a tap fires
    # once; render.py explains why.
    element = "${element}.hit";
    tap_action =
      if marker.kind == "light"
      then {
        action = "call-service";
        service = "homeassistant.toggle";
        service_data.entity_id = marker.entity;
      }
      else {action = "more-info";};
    state_action = [
      (markOn [element] fixtures.markerActive.${marker.kind})
      {
        service = "floorplan.text_set";
        service_data = {
          element = "${element}.state";
          text = markerText.${marker.kind};
        };
      }
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

  outdoorIds = map (r: r.id) (lib.filter (r: r.outdoor or false) geometry.rooms);
  sceneRules = [
    {
      entity = fixtures.daylight;
      element = "fp-scene";
      state_action = datasetSet "daylight" ["fp-scene"] (activeWhen ["above_horizon"]);
    }
    (
      assert lib.assertMsg (lib.elem fixtures.rain.area outdoorIds) "floorplan fixtures: rain area `${fixtures.rain.area}` is not an outdoor room"; {
        inherit (fixtures.rain) entity;
        element = "${fixtures.rain.area}.rain";
        state_action = markOn ["${fixtures.rain.area}.rain"] fixtures.rain.states;
      }
    )
  ];

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
  # Every drawing shows the whole flat, so every card takes the same rules;
  # a room's header adds its markers.
  flatRules = lib.concatLists (lib.mapAttrsToList roomRules checked) ++ doorRules ++ deviceRules ++ personRules ++ sceneRules;

  floorplanCard = {
    image,
    rules,
    style ? "",
  }: {
    type = "custom:floorplan-card";
    # floorplan.css paints the drawing's hidden-line fills in the page
    # background, so the card takes that background too, inside whatever
    # card holds it.
    card_mod.style = ''
      ha-card {
        background: var(--primary-background-color);
        border: none;
        border-radius: 0;
        box-shadow: none;
        ${style}
      }
    '';
    config = {
      inherit image rules;
      stylesheet = url "floorplan.css";
    };
  };
in {
  inherit files;
  # Room for the chips laid over its foot.
  homeCard = floorplanCard {
    image = url "scene.svg";
    rules = flatRules;
    style = "padding-bottom: 28px;";
  };
  roomHeaders = lib.mapAttrs' (id: spec:
    lib.nameValuePair checked.${id}.view (
      {
        card = floorplanCard {
          image.sizes = [
            {
              min_width = 0;
              location = url "focus-${id}-portrait.svg";
              cache = true;
            }
            {
              min_width = 768;
              location = url "focus-${id}-landscape.svg";
              cache = true;
            }
          ];
          rules = flatRules ++ map markerRule spec.markers;
        };
      }
      // lib.getAttrs (lib.filter (key: checked.${id} ? ${key}) ["climate" "motion"]) checked.${id}
    ))
  focus;
  thumbnails = lib.mapAttrs (id: _: url "thumb-${id}.svg") checked;
}
