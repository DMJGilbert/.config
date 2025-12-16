{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-floorplan";
  version = "1.1.3";

  src = fetchurl {
    url = "https://github.com/ExperienceLovelace/ha-floorplan/releases/download/v${version}/floorplan.js";
    hash = "sha256-SaxHXfeSVCzh0dvXwwHnmrABj7gqoCejAAEJba2SIxg=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/floorplan.js
  '';

  meta = with lib; {
    description = "Floorplan for Home Assistant - Bring your SVG floor plans to life";
    homepage = "https://github.com/ExperienceLovelace/ha-floorplan";
    license = licenses.isc;
  };
}
