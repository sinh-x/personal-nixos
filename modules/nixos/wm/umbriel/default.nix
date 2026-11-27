{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.wm.umbriel;
  umbriel = config.programs.umbriel.package;

  # Use documented launcher APIs; do not depend on private upstream unit text.
  # The boundary refuses a live session before stopping stale portals/imports.
  mkSession =
    {
      desktop,
      launcher,
      name,
      command,
    }:
    let
      start = pkgs.writeShellApplication {
        name = launcher;
        runtimeInputs = [
          pkgs.dbus
          pkgs.systemd
        ];
        text = ''
          exec ${pkgs.python3}/bin/python3 ${./session.py} ${desktop} ${command} "$@"
        '';
      };
      entry = pkgs.writeTextDir "share/wayland-sessions/${desktop}.desktop" ''
        [Desktop Entry]
        Name=${name}
        Comment=NX-077 isolated ${desktop} session
        Exec=${start}/bin/${launcher}
        Type=Application
        DesktopNames=${desktop}
      '';
    in
    pkgs.symlinkJoin {
      name = "nx077-${desktop}-session";
      paths = [
        start
        entry
      ];
    };

  niriSession = mkSession {
    desktop = "niri";
    launcher = "niri-session";
    name = "Niri";
    command = "${pkgs.niri}/bin/niri-session";
  };
  umbrielSession = mkSession {
    desktop = "umbriel";
    launcher = "umbriel-trial-session";
    name = "Umbriel (trial)";
    command = "${umbriel}/bin/start-umbriel";
  };
in
{
  imports = [ inputs.umbriel.nixosModules.default ];

  options.modules.wm.umbriel.enable = lib.mkEnableOption "the optional Drgnfly Umbriel trial";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.networking.hostName == "Drgnfly";
        message = "NX-077 Umbriel trial is scoped to Drgnfly.";
      }
      {
        assertion = config.modules.wm.niri.enable && config.modules.wm.niri.greetd.enable;
        message = "NX-077 requires the existing Niri session and greetd fallback.";
      }
      {
        assertion = config.home-manager.users.sinh.sinh-x.wm.umbriel.enable;
        message = "NX-077 requires the matching Umbriel Home Manager configuration.";
      }
    ];

    programs.umbriel.enable = true;

    modules.wm.niri = {
      globalSessionIdentity = false;
      greetd = {
        sessionPackage = niriSession;
        extraSessionPackages = [ umbrielSession ];
      };
    };

    systemd.user = {
      services = {
        # Preserve shared PipeWire, existing Secret Service and Polkit/PAM policy.
        # Restart the common agent with the graphical session, not stale displays.
        polkit-gnome-authentication-agent-1.partOf = [ "graphical-session.target" ];
        niri.wants = [ "niri-session.target" ];
      };
      # Niri v26.04 has no niri-session.target. Supply a trial-gated owner for its
      # legacy watcher rather than silently binding it to a nonexistent target.
      targets.niri-session = {
        description = "Niri-only auxiliary services";
        bindsTo = [ "niri.service" ];
        after = [ "niri.service" ];
      };
    };

    # Backend selection is per desktop, never a global switch from Niri.
    xdg.portal.config = {
      niri = {
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
      umbriel = {
        default = [
          "umbriel"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "umbriel" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "umbriel" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
  };
}
