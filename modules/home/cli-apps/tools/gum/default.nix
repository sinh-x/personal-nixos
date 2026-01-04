{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.gum;
in
{
  options.${namespace}.cli-apps.tools.gum = {
    enable = mkEnableOption "gum - A tool for glamorous shell scripts";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.gum ];
  };
}
