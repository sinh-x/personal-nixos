# Overlay to get latest Claude Code version
# Since v2.1.x, Claude Code ships as a Bun-compiled native binary via
# platform-specific npm packages. We fetch the linux-x64 binary directly.
{ lib, ... }:
_final: prev:
let
  version = "2.1.114";
in
{
  claude-code = prev.stdenv.mkDerivation {
    pname = "claude-code";
    inherit version;

    src = prev.fetchurl {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-${version}.tgz";
      hash = "sha256-wRI9taxQAxhWhoZvdDHMnIMeksKGu6IQQ4LKRAMjAZU=";
    };

    nativeBuildInputs = with prev; [
      makeWrapper
      autoPatchelfHook
    ];

    buildInputs = with prev; [
      stdenv.cc.cc.lib
      zlib
    ];

    # Bun-compiled binary has JS bytecode appended after the ELF.
    # strip corrupts the appended data.
    dontStrip = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -m755 claude $out/bin/claude

      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --unset DEV \
        --prefix PATH : ${
          lib.makeBinPath (
            with prev;
            [
              procps
              bubblewrap
              socat
            ]
          )
        }
    '';

    meta = with lib; {
      description = "CLI for Claude AI assistant";
      homepage = "https://github.com/anthropics/claude-code";
      license = licenses.unfree;
      mainProgram = "claude";
    };
  };
}
