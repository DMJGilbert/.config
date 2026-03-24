{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "lovelace-tabbed-card";
  version = "0.3.3";

  src = fetchurl {
    url = "https://github.com/kinghat/tabbed-card/releases/download/v${version}/tabbed-card.js";
    hash = "sha256-bq1fmXdAtrTxYtJoMqSypvvLwFB7jpRw8PaiUa6OkBo=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/tabbed-card.js
  '';

  meta = with lib; {
    description = "Tabbed card for Home Assistant Lovelace";
    homepage = "https://github.com/kinghat/tabbed-card";
    license = licenses.mit;
  };
}
