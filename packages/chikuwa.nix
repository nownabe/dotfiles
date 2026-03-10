{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "chikuwa";
  version = "0.1.7";

  src = fetchurl {
    url = "https://github.com/nownabe/chikuwa/releases/download/v${version}/chikuwa-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-gBuzI0yhxb2N2lwFI3If43tERoxlZOYWzuXssoTSmAE=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 chikuwa $out/bin/chikuwa
    runHook postInstall
  '';

  meta = {
    description = "A sidebar TUI for monitoring multiple AI agents in tmux sessions";
    homepage = "https://github.com/nownabe/chikuwa";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "chikuwa";
    platforms = [ "x86_64-linux" ];
  };
}
