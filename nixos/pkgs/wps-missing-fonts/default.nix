{ pkgs }:

pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "wps-missing-fonts";
  version = "0.0.1";

  src = ./wps-missing-fonts.zip;

  unpackPhase = ''
    runHook preUnpack
    ${pkgs.unzip}/bin/unzip $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts
    cp -r * $out/share/fonts
    runHook postInstall
  '';
})
