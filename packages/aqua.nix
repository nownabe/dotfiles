{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "aqua";
  version = "2.56.7";

  src = fetchurl {
    url = "https://github.com/aquaproj/aqua/releases/download/v${version}/aqua_linux_amd64.tar.gz";
    hash = "sha256-KMZjNSZUUawNNKNk5Xg25tc+9Vy7lpgmXOPuK5fxx8A=";
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
