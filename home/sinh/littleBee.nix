{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/mpd.nix
  ];

  programs.neve-nvim.enable = true;

  programs.social-apps = {
    discord = true;
    messenger = true;
    slack = false;
    viber = true;
    zoom = true;
  };
}
