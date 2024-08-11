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
    slack = true;
    viber = true;
    zoom = true;
  };

  home.packages = with pkgs; [
    nvim-pkg
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    LEFT_MONITOR = "HDMI-1";
  };
}
