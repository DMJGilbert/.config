{
  stdenv,
  fetchFromGitHub,
  darwin,
}:
stdenv.mkDerivation {
  pname = "janky-borders";
  version = "main";
  src = fetchFromGitHub {
    repo = "JankyBorders";
    owner = "FelixKratz";
    rev = "v1.2.5";
    sha256 = "sha256-cq1XGaTN3/eZ91td6qcj8VwSWiaMDJ7SZzQNNSVCThg=";
  };

  patches = [./patches/janky-borders.patch];

  buildInputs = with darwin.apple_sdk.frameworks; [
    CoreGraphics
    ApplicationServices
    AppKit
    darwin.apple_sdk_11_0.frameworks.SkyLight
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/borders $out/bin
  '';

  meta = {
    description = "Borders around active windows";
    platforms = ["x86_64-darwin" "aarch64-darwin"];
  };
}
