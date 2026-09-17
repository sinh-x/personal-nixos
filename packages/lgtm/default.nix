{
  lib,
  fetchurl,
  stdenv,
}:
let
  pname = "lgtm";
  version = "0.1.5";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/kunkka19xx/lgtm/releases/download/v${version}/lgtm-x86_64-linux.tar.gz";
    hash = "sha256-/e3UAOYgdWrlk9SItNYk9qmBiDT84hqzcAIDb/2koRc=";
  };

  sourceRoot = ".";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 lgtm "$out/bin/lgtm"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Terminal UI for reviewing Git diffs";
    homepage = "https://github.com/kunkka19xx/lgtm";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "lgtm";
    platforms = [ "x86_64-linux" ];
  };
}
