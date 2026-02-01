{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.tools.gurk;
in
{
  options.${namespace}.cli-apps.tools.gurk = {
    enable = mkEnableOption "gurk - A Signal Messenger client for the terminal";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.gurk-rs ];
  };
}
