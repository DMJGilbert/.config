{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "modern-circular-gauge";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "selvalt7";
    repo = "modern-circular-gauge";
    rev = "v${version}";
    hash = "sha256-1ckhyi2kwa8z4c9311qx0lihn1g03vry0pz922crni6dgfd8a3s9=";
  };

  installPhase = ''
    mkdir $out
    cp -v dist/modern-circular-gauge.js $out/
  '';

  meta = with lib; {
    description = "Modern circular gauge card for Home Assistant";
    homepage = "https://github.com/selvalt7/modern-circular-gauge";
    license = licenses.mit;
  };
}
