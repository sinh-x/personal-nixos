{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.oxker;
in
{
  options.${namespace}.cli-apps.tools.oxker = {
    enable = mkEnableOption "oxker - A simple TUI to view & control docker containers";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.oxker ];
  };
}
