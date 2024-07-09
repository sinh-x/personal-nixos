
{pkgs, ...}: {
  imports = [
    ./global
    ./features/bspwm.nix
  ];

  home.packages = with pkgs; [
    light
  ];

}
