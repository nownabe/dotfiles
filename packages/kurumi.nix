{
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "kurumi";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/nownabe/kurumi/releases/download/v${version}/kurumi_${version}_linux_amd64";
    sha256 = "2c70499633bf1baf794fde038515583b838772c3ab6ba706784e0985e2a59ccd";
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
