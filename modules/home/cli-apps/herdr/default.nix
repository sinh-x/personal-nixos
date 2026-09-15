{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.multiplexers.herdr;
  piExtension = pkgs.runCommand "herdr-agent-state.ts" { nativeBuildInputs = [ pkgs.herdr ]; } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME/.pi/agent/extensions"
    herdr integration install pi
    cp "$HOME/.pi/agent/extensions/herdr-agent-state.ts" "$out"
  '';
in
{
  options.${namespace}.cli-apps.multiplexers.herdr = {
    enable = mkEnableOption "Herdr terminal multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.herdr
      pkgs.jq
      pkgs.fzf
    ];

    xdg.configFile."herdr/config.toml".source = ./config.toml;

    home.file.".pi/agent/extensions/herdr-agent-state.ts" = {
      source = piExtension;
      force = true;
    };
  };
}
