# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs ? import <nixpkgs> {}, ...}: rec {
  rgbdaemon = pkgs.callPackage ./rgbdaemon {};
  shellcolord = pkgs.callPackage ./shellcolord {};
  trekscii = pkgs.callPackage ./trekscii {};
  lyrics = pkgs.python3Packages.callPackage ./lyrics {};
  compiz = pkgs.callPackage ./compiz {};
  hyprbars = pkgs.callPackage ./hyprbars {};

  # Personal scripts
  nix-inspect = pkgs.callPackage ./nix-inspect {};
  pass-wofi = pkgs.callPackage ./pass-wofi {};
  xpo = pkgs.callPackage ./xpo {};

  # My slightly customized plymouth theme, just makes the blue outline white
  plymouth-spinner-monochrome = pkgs.callPackage ./plymouth-spinner-monochrome {};

  # example = pkgs.callPackage ./example { };
  wps-missing-fonts = pkgs.callPackage ./wps-missing-fonts {};
  archcraft-icons-fonts = pkgs.callPackage ./archcraft-icons-fonts {};
  ip_update = pkgs.callPackage ./ip_update {};

  wallpapers = import ./wallpapers {inherit pkgs;};
  allWallpapers = pkgs.linkFarmFromDrvs "wallpapers" (pkgs.lib.attrValues wallpapers);

  generateColorscheme = import ./colorschemes/generator.nix {inherit pkgs;};
  colorschemes = import ./colorschemes {inherit pkgs wallpapers generateColorscheme;};
  allColorschemes = let
    # This is here to help us keep IFD cached (hopefully)
    combined = pkgs.writeText "colorschemes.json" (builtins.toJSON (pkgs.lib.mapAttrs (_: drv: drv.imported) colorschemes));
  in
    pkgs.linkFarmFromDrvs "colorschemes" (pkgs.lib.attrValues colorschemes ++ [combined]);
}
