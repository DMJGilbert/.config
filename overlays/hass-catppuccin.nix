{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "hass-catppuccin";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "home-assistant";
    rev = "v${version}";
    hash = "sha256-eUqYlaXNLPfaKn3xcRm5AQwTOKf70JF8cepibBb9KXc=";
  };

  installPhase = ''
    mkdir -p $out
    cp themes/catppuccin.yaml $out/${pname}.yaml
  '';
}
