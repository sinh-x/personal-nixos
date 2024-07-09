
{pkgs, ...}: {
  imports = [
    ./global
    ./features/bspwm.nix
  ];

}
