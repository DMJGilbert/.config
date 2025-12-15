{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "lovelace-stack-in-card";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/custom-cards/stack-in-card/releases/download/${version}/stack-in-card.js";
    hash = "sha256-PrPIkJByd8XknwlR//eHr3APBMMxW+TA162Ujk7wEb0=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir $out
    cp -v $src $out/stack-in-card.js
  '';

  meta = with lib; {
    description = "A custom card that groups other cards into one with no borders";
    homepage = "https://github.com/custom-cards/stack-in-card";
    license = licenses.mit;
  };
}
