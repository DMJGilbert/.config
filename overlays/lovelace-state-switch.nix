{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "lovelace-state-switch";
  version = "1.9.6";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-state-switch";
    rev = version;
    hash = "sha256-wxroVhO8yMVFBghDt8d5fSYg1KF/Vy9vUz/YwW3eU3s=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 state-switch.js $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dynamically replace lovelace cards depending on occasion";
    homepage = "https://github.com/thomasloven/lovelace-state-switch";
    license = licenses.mit;
    maintainers = [];
  };
}
