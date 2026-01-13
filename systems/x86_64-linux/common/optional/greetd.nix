# Add to your configuration.nix
{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --sessions /run/current-system/sw/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

}
