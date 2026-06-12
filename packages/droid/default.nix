{
  lib,
  fetchurl,
  stdenv,
  makeWrapper,
  autoPatchelfHook,
  zlib,
}:
let
  pname = "droid";
  version = "0.144.2";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@factory/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha256-fnF4hducZjo71OFtWixJgcF5xpw+SOiWde9G8zekZec=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  # Bun-compiled binary has JS bytecode appended after the ELF.
  # strip corrupts the appended data.
  dontStrip = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 package/bin/droid "$out/bin/droid"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/droid \
      --set DISABLE_AUTOUPDATER 1 \
      --set DISABLE_INSTALLATION_CHECKS 1
  '';

  meta = with lib; {
    description = "Factory Droid CLI - AI-powered software engineering agent";
    homepage = "https://factory.ai";
    license = licenses.unfree;
    maintainers = [ ];
    mainProgram = "droid";
    platforms = [ "x86_64-linux" ];
  };
}
