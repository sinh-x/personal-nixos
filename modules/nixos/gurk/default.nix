{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.gurk;
in
{
  options.modules.gurk = {
    enable = mkEnableOption "gurk-rs - Signal Messenger client for terminal";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gurk-rs ];
  };
}
