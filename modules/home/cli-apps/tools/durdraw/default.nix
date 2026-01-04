{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.durdraw;
in
{
  options.${namespace}.cli-apps.tools.durdraw = {
    enable = mkEnableOption "durdraw - An ASCII, Unicode and ANSI art editor for the modern UNIX terminal";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.durdraw ];
  };
}
