{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/mpd.nix
    ./features/kitty.nix
    ./features/neovim
  ];

  programs.social-apps = {
    discord = true;
    messenger = true;
    slack = false;
    viber = false;
    zoom = true;
    element = true;
  };

  home.packages = with pkgs; [
    light
    aegisub
  ];

  home.sessionVariables = {
    LEFT_MONITOR = "eDP-1";
  };
}
