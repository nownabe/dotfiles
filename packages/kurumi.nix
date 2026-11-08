{
  lib,
  stdenv,
  fetchurl,
}:

let
  # Renovate looks the release up by its exact tag, so the tag (with "v") is the tracked value.
  tag = "v0.1.0";
  sha256 = "2c70499633bf1baf794fde038515583b838772c3ab6ba706784e0985e2a59ccd";
in
stdenv.mkDerivation rec {
  pname = "kurumi";
  version = lib.removePrefix "v" tag;

  src = fetchurl {
    url = "https://github.com/nownabe/kurumi/releases/download/${tag}/kurumi_${version}_linux_amd64";
    inherit sha256;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/kurumi
    runHook postInstall
  '';

  meta = {
    description = "Append-only encrypted backups to Google Cloud Storage that survive a compromised server";
    homepage = "https://github.com/nownabe/kurumi";
    mainProgram = "kurumi";
    platforms = [ "x86_64-linux" ];
  };
}
