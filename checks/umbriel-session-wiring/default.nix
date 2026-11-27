{
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  baseline = inputs.self.nixosConfigurations.Drgnfly.config;
  # Evaluation-only enablement of the actual translated settings. Host defaults
  # stay disabled; parser and adapter parity checks live in umbriel-trial.
  trial =
    (inputs.self.nixosConfigurations.Drgnfly.extendModules {
      modules = [
        {
          modules.wm.umbriel.enable = true;
          home-manager.users.sinh = {
            ${namespace}.wm.umbriel.enable = true;
          };
        }
      ];
    }).config;
  home = trial.home-manager.users.sinh;
  shell = home.systemd.user.services.noctalia-umbriel;
  watcher = home.systemd.user.services.screenshot-watcher;
  niri = trial.modules.wm.niri;
  greeter = trial.services.greetd.settings;
  otherHosts = map (name: inputs.self.nixosConfigurations.${name}.config) [
    "Elderwood"
    "FireFly"
    "Lily"
  ];
in
assert !baseline.modules.wm.umbriel.enable;
assert !baseline.home-manager.users.sinh.${namespace}.wm.umbriel.enable;
assert baseline.modules.wm.niri.globalSessionIdentity;
assert
  baseline.home-manager.users.sinh.systemd.user.services.screenshot-watcher.Install.WantedBy == [
    "graphical-session.target"
  ];
assert lib.all (host: !host.modules.wm.umbriel.enable) otherHosts;
assert trial.programs.umbriel.enable;
assert trial.programs.niri.enable;
assert trial.systemd.user.targets.niri-session.bindsTo == [ "niri.service" ];
assert trial.systemd.user.targets.niri-session.after == [ "niri.service" ];
assert builtins.elem "niri-session.target" trial.systemd.user.services.niri.wants;
assert
  trial.systemd.user.services.polkit-gnome-authentication-agent-1.partOf
  == [ "graphical-session.target" ];
assert trial.services.gnome.gnome-keyring.enable == baseline.services.gnome.gnome-keyring.enable;
assert niri.greetd.autoLogin == baseline.modules.wm.niri.greetd.autoLogin;
assert greeter.initial_session.user == baseline.services.greetd.settings.initial_session.user;
assert greeter.initial_session.command == "${niri.greetd.sessionPackage}/bin/niri-session";
assert
  greeter.default_session.command
  == "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --sessions ${niri.greetd.sessionPackage}/share/wayland-sessions:${builtins.head niri.greetd.extraSessionPackages}/share/wayland-sessions";
assert builtins.length niri.greetd.extraSessionPackages == 1;
assert !(trial.environment.sessionVariables ? XDG_CURRENT_DESKTOP);
assert !(trial.environment.sessionVariables ? XDG_SESSION_DESKTOP);
assert !(trial.environment.sessionVariables ? XDG_SESSION_TYPE);
assert trial.xdg.portal.config.niri."org.freedesktop.impl.portal.ScreenCast" == "gnome";
assert trial.xdg.portal.config.umbriel."org.freedesktop.impl.portal.ScreenCast" == "umbriel";
assert trial.xdg.portal.config.umbriel."org.freedesktop.impl.portal.FileChooser" == "gtk";
assert !home.programs.noctalia.systemd.enable;
assert !home.programs.noctalia.settings.shell.polkit_agent;
assert shell.Service.Type == "notify";
assert shell.Unit.ConditionEnvironment == "XDG_CURRENT_DESKTOP=umbriel";
assert shell.Unit.After == [ "umbriel.service" ];
assert shell.Unit.Before == [ "graphical-session.target" ];
assert shell.Unit.PartOf == [ "umbriel-session.target" ];
assert shell.Unit.BindsTo == [ "umbriel.service" ];
assert shell.Install.WantedBy == [ "umbriel-session.target" ];
assert watcher.Unit.After == [ "niri-session.target" ];
assert watcher.Unit.PartOf == [ "niri-session.target" ];
assert watcher.Install.WantedBy == [ "niri-session.target" ];
assert home.wayland.systemd.target == baseline.home-manager.users.sinh.wayland.systemd.target;
assert home.systemd.user.services.fcitx5-umbriel.Unit.BindsTo == [ "umbriel.service" ];
assert home.systemd.user.services.fcitx5-umbriel.Install.WantedBy == [ "umbriel-session.target" ];
assert
  home.systemd.user.services.fcitx5-umbriel.Service.ExecStart
  == [ "${trial.i18n.inputMethod.package}/bin/fcitx5" ];
assert lib.all (name: !(builtins.hasAttr name home.systemd.user.services)) [
  "noctalia"
  "waybar"
  "mako"
];
pkgs.runCommand "umbriel-session-wiring" { nativeBuildInputs = [ pkgs.python3 ]; } ''
  # Production-boundary fixtures inject every process call. No real compositor,
  # portal, environment import, lock screen or power action is executed.
  python3 -B ${./test-session.py} ${../../modules/nixos/wm/umbriel/session.py}
  python3 -B ${./test-ipc.py} ${../../modules/home/wm/umbriel/ipc.py}
  echo 'Declared wiring and boundary fixtures passed; live session UAT unverified.' > "$out"
''
