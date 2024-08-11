{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
    ./features/mpd.nix
  ];

  programs.social-apps = {
    discord = true;
  };
}
