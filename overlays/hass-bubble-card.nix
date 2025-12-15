{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "Bubble-Card";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "Clooos";
    repo = "Bubble-Card";
    rev = "v${version}";
    hash = "sha256-04bhixxxpry7bznx3dl93qh7s4q7pqw88as5fqj4dmp2bmd113p3=";
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
