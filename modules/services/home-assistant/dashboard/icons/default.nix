# The dashboard's `fp:` icon set, drawn by icons.py as a frontend module that
# registers it.
{pkgs}: let
  python = pkgs.python3.withPackages (ps: [ps.shapely]);
in
  pkgs.runCommand "hass-fp-icons" {nativeBuildInputs = [python];} ''
    mkdir $out
    python ${./icons.py} $out/fp-icons.js
  ''
