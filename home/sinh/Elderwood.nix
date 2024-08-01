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

  monitors = [
    {
      name = "DP-1";
      width = 3840;
      height = 2160;
      x = 2560;
      workspace = "1";
      primary = true;
    }
    {
      name = "HDMI-1";
      width = 2560;
      height = 1440;
      x = 0;
      workspace = "2";
    }
  ];
  home.sessionVariables.EDITOR = "nvim";
}
