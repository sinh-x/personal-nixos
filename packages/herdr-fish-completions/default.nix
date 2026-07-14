{
  lib,
  herdr,
  runCommand,
}:
runCommand "herdr-fish-completions"
  {
    nativeBuildInputs = [ herdr ];
    meta = with lib; {
      description = "Fish shell completions for herdr, generated at build time from `herdr completion fish`";
      platforms = platforms.all;
    };
  }
  ''
    runHook preBuild
    mkdir -p $out/share/fish/vendor_completions.d
    herdr completion fish > $out/share/fish/vendor_completions.d/herdr.fish
    runHook postBuild
  ''
