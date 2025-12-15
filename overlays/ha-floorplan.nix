{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ha-floorplan";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "ExperienceLovelace";
    repo = "ha-floorplan";
    rev = "v${version}";
    hash = "sha256-02sp4rj1jrfih6nd6f8ybr0sc77bi4m5s2hrxijyrdch64fiwa5c=";
  };

  installPhase = ''
    mkdir $out
    cp -v dist/floorplan.js $out/
    cp -v dist/floorplan-card.js $out/
  '';

  meta = with lib; {
    description = "Floorplan for Home Assistant - Bring your SVG floor plans to life";
    homepage = "https://github.com/ExperienceLovelace/ha-floorplan";
    license = licenses.isc;
  };
}
