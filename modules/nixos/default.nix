# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  imports = [
    ./r_setup.nix
    ./nix_ld.nix
    ./virtualbox.nix
    ./fcitx5.nix
    ./bspwm.nix
    ./hyprland.nix
    ./ip_updater.nix
  ];
}
