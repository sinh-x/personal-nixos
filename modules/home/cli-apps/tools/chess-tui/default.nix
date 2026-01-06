{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.chess-tui;
in
{
  options.${namespace}.cli-apps.tools.chess-tui = {
    enable = mkEnableOption "chess-tui - A TUI for playing chess";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.chess-tui ];
  };
}
