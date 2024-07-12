{
  pkgs,
  libs,
  config,
    ...
}: {
  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
  };

  programs.ncmpcpp = {
    enable = true;
  };

  home.packages = with pkgs; [
    mpc-cli
  ];
}
