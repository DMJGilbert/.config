{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "Bubble-Card";
  version = "2.2.4";

  src = fetchFromGitHub {
    owner = "Clooos";
    repo = "Bubble-Card";
    rev = "v${version}";
    hash = "sha256-vsgu1hvtlppADvaFLeB4xQHbP3wBc6H4p5HbeS3JY80=";
  };

  installPhase = ''
    mkdir $out
    cp -v dist/bubble-card.js $out/
  '';

  meta = with lib; {
    description = "Bubble Card is a minimalist card collection for Home Assistant with a nice pop-up touch";
    homepage = "https://github.com/Clooos/Bubble-Card";
    license = licenses.mit;
    mainProgram = "Bubble-Card";
  };
}
