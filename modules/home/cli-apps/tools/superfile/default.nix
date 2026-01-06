{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.superfile;
in
{
  options.${namespace}.cli-apps.tools.superfile = {
    enable = mkEnableOption "superfile - A pretty and fancy terminal file manager";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.superfile ];
  };
}
