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
    slack = false;
    viber = true;
    zoom = true;
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
