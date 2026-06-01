{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.apps.web.vivaldi;
in
{
  options.${namespace}.apps.web.vivaldi = {
    enable = mkEnableOption "Vivaldi browser";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.vivaldi ];
  };
}
