{
  lib,
  adapter,
  homeDirectory,
  primary,
}:
let
  bindings = import ./bindings.nix { inherit lib adapter homeDirectory; };
  names = [
    "main-term"
    "main-browser"
    "main-code"
    "chat"
    "email"
    "ext-term"
    "ext-browser"
    "ext-code"
  ];
  floatingApps = [
    "pavucontrol"
    "nm-connection-editor"
    "blueman-manager"
    "yad"
    "Viewnior"
    "feh"
    "copyq"
    "gnome-calculator"
  ];
  windowRules =
    map (app: {
      match.app_id = app;
      default_floating = true;
    }) floatingApps
    ++ [
      {
        match.title = "File Operation Progress";
        default_floating = true;
      }
      {
        match.app_id = "one.alynx.showmethekey";
        default_floating = true;
      }
      {
        match.app_id = "showmethekey-gtk";
        default_floating = true;
        default_position = {
          x = 1400;
          y = 2200;
          anchor = "top_left";
        };
        default_floating_size_px = {
          width = 1000;
          height = 150;
        };
      }
      {
        match.app_id = "com.mitchellh.ghostty";
        default_maximize = true;
      }
      {
        match.app_id = [
          "discord"
          "signal"
          "org.telegram.desktop"
          "ViberPC"
          "^viber$" # Native Wayland ID; retain ViberPC for Xwayland.
        ];
        default_workspace = "chat";
        default_maximize = true;
        default_maximize_to_edges = false;
        default_fullscreen = false;
        default_focused = false;
      }
      {
        # ECMAScript regex does not have Rust's inline (?i) flag. Bracket classes
        # retain case-insensitive substring matching without broadening the rule.
        match.app_id = [
          "[cC][oO][dD][eE]"
          "[vV][sS][cC][oO][dD][eE]"
        ];
        default_workspace = "main-code";
      }
      {
        match.app_id = [
          "superProductivity"
        ];
        default_workspace = "email";
        default_focused = false;
      }
      {
        match = {
          app_id = "^org[.]telegram[.]desktop$";
          title = "^Media viewer$";
        };
        default_floating = true;
        default_fullscreen = false;
        default_focused = true;
        default_floating_size = {
          width = 0.33333;
          height = 0.33333;
        };
        default_position = {
          x = 0;
          y = 355;
          anchor = "top";
        };
      }
    ];
in
{
  inherit bindings names;
  ruleLedger =
    (lib.imap1 (index: _: {
      sourceRule = index;
      disposition = "candidate-requires-runtime-comparison";
    }) windowRules)
    ++ [
      {
        sourceRule = 17;
        disposition = "unverified-direct-xwayland-zoom-awaits-consented-metadata";
      }
    ];
  settings = {
    general = {
      mod_key = "Super";
      xwayland = true;
      show_cheatsheet = false;
      autostart = [ "${adapter}/bin/umbriel-trial startup --primary ${lib.escapeShellArg primary}" ];
    };
    environment = {
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      NIXOS_OZONE_WL = "1";
    };
    input = {
      keyboard = {
        layout = "us";
        repeat_delay = 600;
        repeat_rate = 25;
      };
      touchpad = {
        tap = true;
        natural_scroll = false;
        sensitivity = 0.2;
        accel_profile = "adaptive";
      };
      mouse = {
        sensitivity = 0.0;
        accel_profile = "flat";
      };
      focus = {
        follows_mouse = "sloppy";
        follows_mouse_max_scroll = 0.0;
      };
      cursor = {
        theme = "Sweet";
        size = 16;
      };
    };
    layout = {
      mode = "scrolling";
      gap = 10;
      extent_presets = [
        0.33333
        0.5
        0.66667
      ];
      scrolling = {
        default_extent_fraction = 0.5;
        center_focused = "never";
        center_underfull_strip = false;
      };
    };
    appearance = {
      border_width = 2;
      outer_border_width = 4;
      corner_radius = 0;
      shadow.enabled = false;
      title_bar.mode = "off";
    };
    colors.border = {
      focused = "#7fc8ff";
      unfocused = "#505050";
      outer = "#E4A85F";
    };
    output = {
      "LG Display 0x06AA Unknown" = {
        mode = "3840x2400@60.000";
        scale = 1.25;
        position = [
          1920
          0
        ];
      };
      "ASUSTek COMPUTER INC PA248QV L8LMQS149577" = {
        mode = "1920x1200@59.950";
        scale = 1.0;
        position = [
          0
          0
        ];
      };
      "MaxCom Technical Inc 0x1B1A 0x20230808" = {
        mode = "2560x1600@59.995";
        scale = 1.0;
        position = [
          4992
          0
        ];
      };
    };
    # Each name is declared once, qualified to the laptop. The serialized
    # topology adapter moves ext-* at startup/hotplug; internal-only keeps all 8.
    workspace = map (name: {
      inherit name;
      output = primary;
    }) names;
    window_rule = windowRules;
    keybinds = builtins.listToAttrs (
      map (entry: {
        name = entry.target;
        value = entry.binding;
      }) bindings
    );
  };
}
