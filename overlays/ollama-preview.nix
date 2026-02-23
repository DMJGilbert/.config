{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ollama-preview";
  version = "0.14.3-rc3";

  src = fetchurl {
    url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-darwin.tgz";
    sha256 = "0dnpqx7rbkpiik5nmlal509qy66x19g93cfgws8nskin06pdwam9";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ollama $out/bin/ollama
    chmod +x $out/bin/ollama
    runHook postInstall
  '';

  meta = with lib; {
    description = "Ollama - Run large language models locally (preview)";
    homepage = "https://ollama.com";
    license = licenses.mit;
    platforms = ["aarch64-darwin" "x86_64-darwin"];
    mainProgram = "ollama";
  };
}
