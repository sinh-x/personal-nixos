{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    dmenu
    dunst
    feh
    flameshot
    gsettings-qt
    gsimplecal
    input-leap
    killall
    libnotify
    polybar
    rofi
    screenkey
    xclip
    xcolor
    xdg-utils
    xdo
    xdotool
    xfce.thunar
    xorg.xev
    xorg.xinit
  ];
}
