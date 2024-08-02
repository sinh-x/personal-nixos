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

  wallpaper = pkgs.wallpapers.mountain-nebula-purple-pink;

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
  home.sessionVariables.EDITOR = "nvim";
}
