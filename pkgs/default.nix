# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  # example = pkgs.callPackage ./example { };
  wps-missing-fonts = pkgs.callPackage ./wps-missing-fonts { };
  archcraft-icons-fonts = pkgs.callPackage ./archcraft-icons-fonts { };
}
