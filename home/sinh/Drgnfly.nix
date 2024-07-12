
{pkgs, ...}: {
  imports = [
    ./global
    ./features/bspwm.nix
    ./features/mpd.nix
  ];

  home.packages = with pkgs; [
    light
  ];

}
