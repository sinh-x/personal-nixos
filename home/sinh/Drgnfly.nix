{ pkgs, ... }:
{
  imports = [ ./global ];

  home.packages = with pkgs; [
    light
    aegisub
    viber
  ];

  sinh-x.social-apps = {
    viber = true;
  };

  home.sessionVariables = {
    LEFT_MONITOR = "eDP-1";
  };
}
