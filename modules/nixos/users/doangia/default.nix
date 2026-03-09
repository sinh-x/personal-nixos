{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.users.doangia;
in
{
  options.modules.users.doangia = {
    enable = mkEnableOption "doangia user account";
  };

  config = mkIf cfg.enable {
    programs.fish.enable = true;

    sops.secrets."users/doangia/hashedPassword" = {
      neededForUsers = true;
    };

    users.users.doangia = {
      isNormalUser = true;
      extraGroups = [
        "network"
        "video"
        "audio"
      ];
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets."users/doangia/hashedPassword".path;
      packages = [ pkgs.home-manager ];
    };

    home-manager.users.doangia = import ../../../../home/doangia;
  };
}
