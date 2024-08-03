{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/mpd.nix
    ./features/kitty.nix
  ];

  programs.neve-nvim.enable = true;

  programs.social-apps = {
    discord = true;
    messenger = true;
    slack = true;
    viber = true;
    zoom = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    LEFT_MONITOR = "HDMI-1";
  };
}
