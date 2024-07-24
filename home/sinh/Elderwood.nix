{pkgs, ...}: {
  imports = [
    ./global
    ./features/bspwm.nix
    ./features/mpd.nix
  ];

  programs.neve-nvim.enable = true;
}
