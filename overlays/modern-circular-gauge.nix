{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "modern-circular-gauge";
  version = "0.13.1";

  src = fetchurl {
    url = "https://github.com/selvalt7/modern-circular-gauge/releases/download/v${version}/modern-circular-gauge.js";
    hash = "sha256-BU5j/o9tBBD7JjIYvlZZPVV0OGNq5t5hyDblf3dTGIY=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/modern-circular-gauge.js
  '';

  meta = with lib; {
    description = "Modern circular gauge card for Home Assistant";
    homepage = "https://github.com/selvalt7/modern-circular-gauge";
    license = licenses.mit;
  };
}
