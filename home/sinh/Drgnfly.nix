{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/bspwm.nix
    ./features/mpd.nix
  ];

  home.packages = with pkgs; [
    light

    inputs.Neve.packages.x86_64-linux.default
    statix
    selene
    alejandra
    rustfmt
  ];
}
