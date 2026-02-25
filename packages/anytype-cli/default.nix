{
  lib,
  fetchurl,
  stdenv,
}:
let
  pname = "anytype-cli";
  version = "0.1.8";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/anyproto/anytype-cli/releases/download/v${version}/anytype-cli-v${version}-linux-amd64.tar.gz";
    hash = "sha256-a5poD6oaw+8awHn3SMVovwTViCe4UEJERG+fv8OA9y8=";
  };

  sourceRoot = ".";

  dontBuild = true;
  dontFixup = true; # statically linked, no patching needed

  installPhase = ''
    runHook preInstall
    install -Dm755 anytype "$out/bin/anytype-cli"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line interface for Anytype - headless server and scripting";
    homepage = "https://github.com/anyproto/anytype-cli";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "anytype-cli";
    platforms = [ "x86_64-linux" ];
  };
}
