{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mo";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/k1LoW/mo/releases/download/v${version}/mo_v${version}_linux_amd64.tar.gz";
    hash = "sha256-BJn7yOmd2Ilb63BJo4La/KCGTxM28xFotKGwL09RYxM=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 mo $out/bin/mo
    runHook postInstall
  '';

  meta = {
    description = "Markdown viewer using browser";
    homepage = "https://github.com/k1LoW/mo";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mo";
    platforms = [ "x86_64-linux" ];
  };
}
