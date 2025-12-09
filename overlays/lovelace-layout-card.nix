{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "lovelace-layout-card";
  version = "2.4.7";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-layout-card";
    rev = "v${version}";
    hash = "sha256-xni9cTgv5rdpr+Oo4Zh/d/2ERMiqDiTFGAiXEnigqjc=";
  };

  installPhase = ''
    mkdir $out
    cp -v layout-card.js $out/
  '';

  meta = with lib; {
    description = "Get more control over the placement of lovelace cards";
    homepage = "https://github.com/thomasloven/lovelace-layout-card";
    license = licenses.mit;
  };
}
