{
  inputs,
  pkgs,
  config,
  lib,
  outputs,
  ...
}: {
  users.mutableUsers = true;
  users.users.sinh = {
     isNormalUser = true;
      extraGroups = [ 
        "wheel" "network" "power" "video" "audio"
        "tty" "dialout"
      ];
      
    packages = [pkgs.home-manager];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      sinh = import ../../../../home/sinh/${config.networking.hostName}.nix;
    };
  };
}
