{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "lovelace-stack-in-card";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "custom-cards";
    repo = "stack-in-card";
    rev = version;
    hash = "sha256-EVv1C6AcrYeMS5lYDRodkl3CTRpbg3szi1uhDc3boZ4=";
  };

  installPhase = ''
    mkdir $out
    cp -v dist/stack-in-card.js $out/
  '';

  meta = with lib; {
    description = "A custom card that groups other cards into one with no borders";
    homepage = "https://github.com/custom-cards/stack-in-card";
    license = licenses.mit;
  };
}
