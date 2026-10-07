{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libnl,
}:
# python-matter-server shells out to `chip-ota-provider-app` from PATH to serve
# firmware during a Matter OTA update. nixpkgs does not build it from
# connectedhomeip, so this repackages the prebuilt binary the upstream
# matter-server Docker image downloads (pinned to the same release).
stdenv.mkDerivation rec {
  pname = "chip-ota-provider-app";
  version = "2025.9.0";

  src = fetchurl {
    url = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/${version}/chip-ota-provider-app-x86-64";
    hash = "sha256-RVDfevZSnkYgRj0cASf4MOwkBMgXrUxjQ7KeMs7AFE4=";
  };

  dontUnpack = true;

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [
    libnl
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/chip-ota-provider-app
    runHook postInstall
  '';

  meta = {
    description = "Matter OTA provider example app from connectedhomeip, used by python-matter-server";
    homepage = "https://github.com/home-assistant-libs/matter-linux-ota-provider";
    license = lib.licenses.asl20;
    mainProgram = "chip-ota-provider-app";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
