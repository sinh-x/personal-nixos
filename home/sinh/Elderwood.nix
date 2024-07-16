
{pkgs, ...}: {
  imports = [
    ./global
    ./features/bspwm.nix
    ./features/mpd.nix
  ];


}
