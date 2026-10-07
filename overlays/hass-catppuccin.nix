{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "hass-catppuccin";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "home-assistant";
    rev = "v${version}";
    hash = "sha256-+m6lWer9a4AwmTgckhSHOKd0Oo6x9N0jjza4/F0ye3E=";
  };

  installPhase = ''
    mkdir -p $out
    cp themes/catppuccin.yaml $out/${pname}.yaml
  '';

  meta = with lib; {
    description = "Catppuccin theme for Home Assistant";
    homepage = "https://github.com/catppuccin/home-assistant";
    license = licenses.mit;
  };
}
