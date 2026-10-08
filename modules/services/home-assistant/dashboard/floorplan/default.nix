# Isometric floorplan card: the drawings and stylesheet are built from
# geometry.nix and tiles.nix, and the ha-floorplan rules that animate them
# are generated from the same tiles, so element ids cannot drift apart.
#
# `files` is served at `baseUrl`; `card` is the Lovelace card config.
# `viewPaths` are the room views that exist, to catch a tile linking nowhere.
{
  lib,
  pkgs,
  viewPaths,
  baseUrl ? "/local/floorplan",
}: let
  geometry = import ./geometry.nix;
  tiles = import ./tiles.nix;

  roomIds = map (r: r.id) geometry.rooms;
  checked =
    lib.mapAttrs (
      id: room:
        assert lib.assertMsg (lib.elem id roomIds) "floorplan tiles: no room `${id}` in geometry.nix";
        assert lib.assertMsg (lib.elem room.view viewPaths) "floorplan tiles: ${id} links to missing view `${room.view}`"; room
    )
    tiles;

  json = name: value: pkgs.writeText name (builtins.toJSON value);
  python = pkgs.python3.withPackages (ps: [ps.shapely ps.fonttools]);
  icons = "${pkgs.material-design-icons}/share/fonts/truetype/materialdesignicons-webfont.ttf";

  files = pkgs.runCommand "hass-floorplan" {nativeBuildInputs = [python];} ''
    mkdir $out
    for layout in landscape portrait; do
      python ${./render.py} ${json "geometry.json" geometry} "$out/$layout.svg" \
        --tiles ${json "tiles.json" checked} --icons ${icons} --layout "$layout"
    done
    cp ${./floorplan.css} $out/floorplan.css
  '';

  # /local is served with a long max-age; the store hash changes the URL
  # exactly when the files change.
  url = file: "${baseUrl}/${file}?v=${builtins.substring 11 8 "${files}"}";

  # ha-floorplan evaluates these in a sandboxed interpreter, so they keep to
  # plain expressions.
  activeWhen = states: "\${${builtins.toJSON states}.includes(entity.state) ? \"1\" : \"0\"}";
  valueText = tile: ''> const v = parseFloat(entity.state); return isNaN(v) ? "–" : v.toFixed(${toString tile.digits}) + "${tile.unit}";'';
  labelText = tile: ''> return ${builtins.toJSON tile.labels}[entity.state] || "–";'';

  markOn = elements: states: {
    service = "floorplan.dataset_set";
    service_data = {
      inherit elements;
      key = "on";
      value = activeWhen states;
    };
  };

  roomRules = id: room: let
    navigate = {
      action = "navigate";
      navigation_path = "/lovelace-home/room-${room.view}";
    };
    tileRule = k: tile: let
      element = "${id}.tile${toString k}";
    in {
      inherit (tile) entity;
      inherit element;
      # Taps on a tile reach the strip's rule, which covers its children.
      state_action =
        lib.optional (tile ? active) (markOn [element] tile.active)
        ++ [
          {
            service = "floorplan.text_set";
            service_data = {
              element = "${element}.text";
              text =
                if tile ? labels
                then labelText tile
                else valueText tile;
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
        element = "${id}.strip";
        tap_action = navigate;
      }
    ]
    ++ lib.imap0 tileRule room.tiles;
in {
  inherit files;
  card = {
    type = "custom:floorplan-card";
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
      rules = lib.concatLists (lib.mapAttrsToList roomRules checked);
    };
  };
}
