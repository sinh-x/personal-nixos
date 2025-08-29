# Add to your configuration.nix
{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Make Hyprland available as session
  environment.etc."greetd/environments".text = ''
    Hyprland
  '';
}
