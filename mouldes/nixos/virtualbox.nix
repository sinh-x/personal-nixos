{ config, pkgs, lib, ... }:

let
  cfg = config.modules.virtualbox;
in {
  options = {
    modules.virtualbox.enable = lib.mkEnableOption "R and r-packages installation";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      virtualbox
    ];
  };
}
