{ config, pkgs, ... }:
{
  users = {
    # Define plugdev group for QMK/udev rules
    groups.plugdev = { };

    mutableUsers = true;

    users.sinh = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "network"
        "power"
        "video"
        "audio"
        "tty"
        "docker"
        "dialout"
        "plugdev"
        "wpa_supplicant"
      ]
      ++ (if config.virtualisation.virtualbox.host.enable or false then [ "vboxusers" ] else [ ]);

      shell = pkgs.fish;

      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCh+hN2O6uIjq/JEftHeIM8JWl0mL9IKBgl1+PlrGUPFonHzCQDcKuIyTODOj2m+L99eGB8wLQovJhZTbAfQzjHnR9qbGVWTZPxGg0XI7VSOkTX0oM1UgLNzANyhrEvdJUXuO64PTP0JwNa2nDR92N3Tg1kugaeIZ83493aqQT7FnLwT9VzrO1FFdqmrWtgpKZyjoQzEOXk13AvTIjItcx0MJTtePh9ogJwmSleR42FBT++U8otLbx8iCov7l7n/PUSiJH2blrsSZtg0KT4r05vbHcZVtdODWWxlumLA3Kjnv6VCXnpjOnLbs+eds/FyugT8oxOjsx3yFQLzYbXWJBR sinh"
      ];

      packages = [ pkgs.home-manager ];
    };
  };

  home-manager.users.sinh = import ../../../../home/sinh/${config.networking.hostName}.nix;

  security.pam.services = {
    swaylock = { };
  };
}
