
{pkgs, ...}: {
  imports = [
    ./global
    ./features/bspwm.nix
    ./features/mpd.nix
  ];

  services.ip_updater = {
    enable = true;
    package = pkgs.ip_update;
  };

}
