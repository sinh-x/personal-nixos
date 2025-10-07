{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.wm.hyprland;
in
{
  options = {
    modules.wm.hyprland.enable = lib.mkEnableOption "hyprland";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
        package = pkgs.hyprland;
        portalPackage = pkgs.xdg-desktop-portal-hyprland;
      };
      hyprlock.enable = true;
    };

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      # Add these for better compatibility
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    # hardware = {
    #   opengl.enable = true;
    #   # Add for better performance
    #   opengl.driSupport = true;
    #   opengl.driSupport32Bit = true;
    # };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    # Add audio support
    security.rtkit.enable = true;
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      # Enable services for file manager
      gvfs.enable = true; # For thunar
      tumbler.enable = true; # Thumbnails
    };

    # Add polkit for authentication
    security.polkit.enable = true;
    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      # Your existing packages
      pyprland
      pastel
      pywal
      swaybg
      gojq
      tofi
      yad
      hyprpicker
      hyprshot
      mako
      waybar
      wofi
      wofi-pass
      foot
      eww
      libnotify
      swww
      wl-clipboard
      wl-clip-persist
      cliphist
      wlroots
      wlr-randr
      qt5.qtwayland

      # Additional essential packages
      # Screenshots & screen recording
      grim # Screenshot utility
      slurp # Area selection for screenshots
      wf-recorder # Screen recording

      # System utilities
      brightnessctl # Brightness control (better than light for Wayland)
      playerctl # Media player control
      pamixer # PulseAudio mixer
      pulsemixer
      pavucontrol # Volume control GUI
      socat

      # File management
      xfce.thunar # File manager
      xfce.tumbler # Thumbnails for thunar

      # Clipboard & utilities
      wl-clipboard # Standard Wayland clipboard
      cliphist # Clipboard history

      # Launchers & menus (alternatives/additions to wofi)
      rofi # Rofi for Wayland
      fuzzel # Fast application launcher

      # System info & monitoring
      btop # System monitor

      # Network & Bluetooth
      blueman # Bluetooth manager

      # Image viewers & editors
      viewnior # Image viewer
      gimp # Image editor

      # Your Hyprland plugins
      inputs.hyprhook.packages.x86_64-linux.hyprhook
      hyprcursor
    ];

    # Enable dconf for GTK apps
    programs.dconf.enable = true;

    # Font configuration
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-emoji
        font-awesome
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "JetBrainsMono Nerd Font" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };

    # Enable location service for automatic dark/light theme switching
    location.provider = "geoclue2";
    services.geoclue2.enable = true;
  };
}

# {
#   inputs,
#   config,
#   pkgs,
#   lib,
#   ...
# }:
# let
#   cfg = config.modules.hyprland;
# in
# {
#   options = {
#     modules.hyprland.enable = lib.mkEnableOption "hyprland";
#   };
#   config = lib.mkIf cfg.enable {
#     programs.hyprland = {
#       enable = true;
#       xwayland.enable = true;
#       package = pkgs.hyprland;
#     };
#     programs.hyprlock.enable = true;
#
#     environment.sessionVariables = {
#       WLR_NO_HARDWARE_CURSORS = "1";
#       NIXOS_OZONE_WL = "1";
#     };
#
#     hardware = {
#       opengl.enable = true;
#     };
#
#     xdg.portal = {
#       enable = true;
#       extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
#       config.common.default = "*";
#     };
#
#     environment.systemPackages = with pkgs; [
#       pyprland
#       swaybg
#       gojq
#       tofi
#       yad
#       hyprpicker
#       hyprshot
#       mako
#       waybar
#       wofi
#       wofi-pass
#       foot
#       eww
#       libnotify
#       swww
#       wl-clipboard-rs
#       wlroots
#       wlr-randr
#
#       qt5.qtwayland
#
#       inputs.hyprhook.packages.x86_64-linux.hyprhook
#       hyprlandPlugins.hycov
#     ];
#   };
# }
