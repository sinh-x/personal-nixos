{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.below;
in
{
  options.${namespace}.cli-apps.tools.below = {
    enable = mkEnableOption "below - A time traveling resource monitor";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.below ];
  };
}
