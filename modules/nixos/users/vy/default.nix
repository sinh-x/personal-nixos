{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.users.vy;
in
{
  options.modules.users.vy = {
    enable = mkEnableOption "vy user account";
  };

  config = mkIf cfg.enable {
    programs.fish.enable = true;

    sops.secrets."users/vy/hashedPassword" = {
      neededForUsers = true;
    };

    users.users.vy = {
      isNormalUser = true;
      extraGroups = [
        "network"
        "video"
        "audio"
      ];
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets."users/vy/hashedPassword".path;
      packages = [ pkgs.home-manager ];
    };

    home-manager.users.vy = import ../../../../home/vy;
  };
}
