{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "chikuwa";
  version = "0.1.8";

  src = fetchurl {
    url = "https://github.com/nownabe/chikuwa/releases/download/v${version}/chikuwa-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-MtrZa6FXPw6+AjlY7RLSmhoZWotQ6f8giGc3hoXJn6s=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

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
