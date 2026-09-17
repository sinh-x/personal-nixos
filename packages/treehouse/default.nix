{
  lib,
  fetchurl,
  stdenv,
}:
let
  pname = "treehouse";
  version = "2.3.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/kunchenguid/treehouse/releases/download/v${version}/treehouse-v${version}-linux-amd64.tar.gz";
    hash = "sha256-lP0rLCDDWqwd3ClBMXiQrYLJkW9czsusSlDNp4Pu0Q8=";
  };

  sourceRoot = ".";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 treehouse "$out/bin/treehouse"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Git worktree manager for coding agents";
    homepage = "https://github.com/kunchenguid/treehouse";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "treehouse";
    platforms = [ "x86_64-linux" ];
  };
}
