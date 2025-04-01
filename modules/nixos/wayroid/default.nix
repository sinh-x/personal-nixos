{ config, lib, ... }:

let
  cfg = config.modules.waydroid;
in
{
  options = {
    modules.waydroid.enable = lib.mkEnableOption "Virtualbox modules";
  };
  config = lib.mkIf cfg.enable {
    virtualisation = {
      waydroid.enable = true;
      lxd.enable = true;
    };
  };
}
