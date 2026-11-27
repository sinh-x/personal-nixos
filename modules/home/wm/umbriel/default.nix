{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  osConfig ? null,
  ...
}:
let
  cfg = config.${namespace}.wm.umbriel;
  primary = config.${namespace}.wm.niri.monitors.primary;
  primaryOutput = if primary == null then "eDP-1" else primary;
  adapter = pkgs.writeShellApplication {
    name = "umbriel-trial";
    runtimeInputs = [
      pkgs.rofi
      pkgs.libnotify
    ];
    text = ''
      exec ${pkgs.python3}/bin/python3 ${./ipc.py} "$@"
    '';
  };
  desktop = import ./settings.nix {
    inherit lib adapter;
    inherit (config.home) homeDirectory;
    primary = primaryOutput;
  };
  noctalia = pkgs.writeShellApplication {
    name = "noctalia-umbriel";
    runtimeInputs = config.programs.noctalia.extraPackages;
    text = ''
      exec ${lib.getExe config.programs.noctalia.package} "$@"
    '';
  };
in
{
  imports = [
    inputs.umbriel.homeModules.default
    inputs.noctalia.homeModules.default
  ];

  options.${namespace}.wm.umbriel.enable =
    lib.mkEnableOption "the optional Drgnfly Umbriel/Noctalia trial";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig != null && osConfig.modules.wm.umbriel.enable;
        message = "NX-077 requires the matching Drgnfly NixOS Umbriel session.";
      }
      {
        assertion = config.${namespace}.wm.niri.enable;
        message = "NX-077 must retain the Niri Home Manager configuration.";
      }
      {
        assertion = config.programs.umbriel.settings != null;
        message = "NX-077 needs its translated Umbriel configuration before activation; upstream defaults are not parity.";
      }
      {
        assertion = !config.programs.noctalia.systemd.enable;
        message = "NX-077 owns Noctalia through umbriel-session.target, not the global Home Manager target.";
      }
    ];

    programs = {
      umbriel = {
        enable = true;
        inherit (desktop) settings;
      };
      noctalia = {
        enable = true;
        # Do not retarget wayland.systemd.target for unrelated HM services.
        systemd.enable = false;
        settings.shell = {
          polkit_agent = false;
          clipboard_enabled = true;
        };
      };
    };

    # The Niri watcher deliberately exports image AND path. It must never react
    # to an explicit Save in the trial, even when both use the same directory.
    ${namespace}.wm.niri.screenshotWatcherTarget = "niri-session.target";

    home.packages = [ adapter ];

    systemd.user.services = {
      umbriel-workspaces = {
        Unit = {
          Description = "Umbriel named-workspace topology reconciliation";
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=umbriel";
          After = [ "umbriel.service" ];
          PartOf = [ "umbriel-session.target" ];
          BindsTo = [ "umbriel.service" ];
        };
        Service = {
          ExecStart = "${adapter}/bin/umbriel-trial watch --primary ${primaryOutput}";
          Restart = "on-failure";
          RestartSec = 2;
          TimeoutStopSec = 5;
        };
        Install.WantedBy = [ "umbriel-session.target" ];
      };
      noctalia-umbriel = {
        Unit = {
          Description = "Noctalia shell for the optional Umbriel session";
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=umbriel";
          After = [ "umbriel.service" ];
          Before = [ "graphical-session.target" ];
          PartOf = [ "umbriel-session.target" ];
          BindsTo = [ "umbriel.service" ];
        };
        Service = {
          Type = "notify";
          ExecStart = lib.getExe noctalia;
          Restart = "on-failure";
          TimeoutStartSec = 30;
          TimeoutStopSec = 10;
        };
        Install.WantedBy = [ "umbriel-session.target" ];
      };

      # Niri keeps its existing compositor-owned startup. The trial starts one
      # Fcitx client from the same host package/addons, never from two autostarts.
      fcitx5-umbriel = {
        Unit = {
          Description = "Fcitx5 for Umbriel (existing host addons and Lotus server)";
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=umbriel";
          After = [ "umbriel.service" ];
          PartOf = [ "umbriel-session.target" ];
          BindsTo = [ "umbriel.service" ];
        };
        Service = {
          ExecStart = "${osConfig.i18n.inputMethod.package}/bin/fcitx5";
          Restart = "on-failure";
          TimeoutStopSec = 10;
        };
        Install.WantedBy = [ "umbriel-session.target" ];
      };
    };
  };
}
