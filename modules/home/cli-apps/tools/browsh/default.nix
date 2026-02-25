{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.browsh;
in
{
  options.${namespace}.cli-apps.tools.browsh = {
    enable = mkEnableOption "browsh - A fully-modern text-based browser, rendering to TTY and browsers";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.browsh ];
  };
}
