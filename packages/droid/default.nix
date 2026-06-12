{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
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

  nativeBuildInputs = [ autoPatchelfHook ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 package/bin/droid "$out/bin/droid"
    runHook postInstall
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
