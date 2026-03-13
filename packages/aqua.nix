{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "aqua";
  version = "2.57.0";

  src = fetchurl {
    url = "https://github.com/aquaproj/aqua/releases/download/v${version}/aqua_linux_amd64.tar.gz";
    hash = "sha256-BCFG/sa3qubtYSP9UDMUR0Ssqpr6R23ZpH4qrVDV1cY=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 aqua $out/bin/aqua
    runHook postInstall
  '';

  meta = {
    description = "Declarative CLI Version Manager written in Go";
    homepage = "https://aquaproj.github.io/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "aqua";
    platforms = [ "x86_64-linux" ];
  };
}
