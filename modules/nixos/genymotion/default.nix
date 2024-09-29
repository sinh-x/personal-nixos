{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.genymotion;
in
{
  options = {
    modules.genymotion.enable = lib.mkEnableOption "Genymotion";
  };
  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ genymotion ];
  };
}
