{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "modern-circular-gauge";
  version = "0.15.0";

  src = fetchurl {
    url = "https://github.com/selvalt7/modern-circular-gauge/releases/download/v${version}/modern-circular-gauge.js";
    hash = "sha256-MX7KXW0xr4b4tx0avIdmypgj9xQPdM3LY3+Q+LtmmMo=";
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
