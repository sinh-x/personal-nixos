{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.sc-im;
in
{
  options.${namespace}.cli-apps.tools.sc-im = {
    enable = mkEnableOption "sc-im - An ncurses spreadsheet program for terminal";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.sc-im ];
  };
}
