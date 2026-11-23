{
  lib,
  stdenvNoCC,
  fetchurl,
  buildFHSEnv,
}:
let
  version = "9.9.3";
  binary = stdenvNoCC.mkDerivation {
    pname = "neon-cli-unwrapped";
    inherit version;

    # Official standalone release bundles Node 22; no host Node required.
    src = fetchurl {
      url = "https://github.com/neondatabase/neon-pkgs/releases/download/neon%40${version}/neon-linux-x64";
      hash = "sha256-XtBQLGSYmNb8vYyG8M12LKyfaCqKXdAOA1a3Uw3900U=";
    };

    dontUnpack = true;
    # pkg embeds absolute payload offsets: even patchelf corrupts this binary.
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/neon"
      runHook postInstall
    '';
  };
in
# Keep separate from nixpkgs' unrelated neon HTTP/WebDAV library.
buildFHSEnv {
  pname = "neon";
  inherit version;
  targetPkgs = pkgs: [ pkgs.stdenv.cc.cc.lib ];
  runScript = "${binary}/bin/neon";

  meta = {
    description = "Official Neon CLI for serverless Postgres and cloud backend primitives";
    homepage = "https://neon.com/docs/cli/install";
    changelog = "https://github.com/neondatabase/neon-pkgs/releases/tag/neon%40${version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "neon";
    platforms = [ "x86_64-linux" ];
  };
}
