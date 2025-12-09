{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "lovelace-tabbed-card";
  version = "v0.3.2";

  src = fetchFromGitHub {
    owner = "kinghat";
    repo = "tabbed-card";
    rev = version;
    hash = "sha256-Es8YHACUvbBIay1BzElBTtxdxdD7Hs1RrjGgm2C6BUU=";
  };

  npmDepsHash = "sha256-R+HhIghy15q8SM4NtwNMK5xw7tKNQsKZAYU7ygQErjE=";

  makeCacheWritable = true;

  postPatch = ''
    cp ${./tabbed-card-package-lock.json} package-lock.json
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    install -m0644 dist/tabbed-card.js $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.mit;
    maintainers = [];
  };
}
