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

  programs.neve-nvim.enable = false;

  programs.social-apps = {
    discord = true;
    messenger = true;
    slack = false;
    viber = true;
    zoom = true;
    element = true;
  };

  home.packages = with pkgs; [
    light

    aegisub
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    LEFT_MONITOR = "eDP-1";
  };
}
