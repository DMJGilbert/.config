{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-floorplan";
  version = "1.1.5";

  src = fetchurl {
    url = "https://github.com/ExperienceLovelace/ha-floorplan/releases/download/v${version}/floorplan.js";
    hash = "sha256-3ysiUqoRMBHuZeUo2t5KLh92mGmySI2u5U96pZ6Zads=";
  };

  dontUnpack = true;

  # A rule with both tap and hold actions binds its tap to "click", which
  # also fires when a long press is released, so a hold runs the tap too (a
  # light tile toggles as its pop-up opens). The long-press observer already
  # dispatches "shortClick" for clicks that were not long presses; listen
  # for that instead when the rule has a hold action.
  installPhase = ''
    mkdir -p $out
    cp $src $out/floorplan.js
    substituteInPlace $out/floorplan.js --replace-fail \
      'e&&!s&&Ji.on(a,"click",this.onClick.bind(c))' \
      'e&&!s&&Ji.on(a,r?.rule?.hold_action?"shortClick":"click",this.onClick.bind(c))'
  '';

  meta = with lib; {
    description = "Floorplan for Home Assistant - Bring your SVG floor plans to life";
    homepage = "https://github.com/ExperienceLovelace/ha-floorplan";
    license = licenses.isc;
  };
}
