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

  # render() draws nothing until hass is set, but the hass setter never
  # requests an update: a card whose children are built before hass arrives
  # stays blank until some other change re-renders it. Requesting an update
  # when hass is first set fixes the empty cards on first page load.
  installPhase = ''
    mkdir $out
    cp -v $src $out/stack-in-card.js
    substituteInPlace $out/stack-in-card.js --replace-fail \
      'set hass(t){this._hass=t,this._card&&(this._card.hass=t)}' \
      'set hass(t){const f=!this._hass;this._hass=t,this._card&&(this._card.hass=t),f&&this.requestUpdate()}'
  '';

  meta = with lib; {
    description = "A custom card that groups other cards into one with no borders";
    homepage = "https://github.com/custom-cards/stack-in-card";
    license = licenses.mit;
  };
}
