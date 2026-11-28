{
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  actual = inputs.self.nixosConfigurations.Drgnfly.config;
  # Exercise session selection and both login modes independently of the host.
  fixture =
    {
      enabled,
      defaultSession ? false,
      autoLogin ? true,
    }:
    (inputs.self.nixosConfigurations.Drgnfly.extendModules {
      modules = [
        {
          modules.wm.umbriel = {
            enable = lib.mkForce enabled;
            defaultSession = lib.mkForce defaultSession;
          };
          modules.wm.niri.greetd.autoLogin.enable = lib.mkForce autoLogin;
          home-manager.users.sinh = {
            ${namespace}.wm.umbriel.enable = lib.mkForce enabled;
          };
        }
      ];
    }).config;
  baseline = fixture { enabled = false; };
  trial = fixture { enabled = true; };
  primary = fixture {
    enabled = true;
    defaultSession = true;
  };
  passwordLogin = fixture {
    enabled = true;
    defaultSession = true;
    autoLogin = false;
  };
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
assert
  actual.modules.wm.umbriel.enable == actual.home-manager.users.sinh.${namespace}.wm.umbriel.enable;
assert !baseline.modules.wm.umbriel.enable;
assert !baseline.home-manager.users.sinh.${namespace}.wm.umbriel.enable;
assert baseline.modules.wm.niri.globalSessionIdentity;
assert baseline.modules.wm.niri.greetd.sessionExecutable == "niri-session";
assert
  baseline.services.greetd.settings.initial_session.command
  == "${baseline.modules.wm.niri.greetd.sessionPackage}/bin/niri-session";
assert !baseline.home-manager.users.sinh.${namespace}.wm.niri.isolateShellServices;
assert
  baseline.home-manager.users.sinh.systemd.user.services.screenshot-watcher.Install.WantedBy == [
    "graphical-session.target"
  ];
assert lib.all (host: !host.modules.wm.umbriel.enable) otherHosts;
assert trial.programs.umbriel.enable;
assert trial.programs.niri.enable;
assert trial.systemd.user.targets.niri-session.bindsTo == [ "niri.service" ];
assert !trial.systemd.user.targets.niri-session.unitConfig.DefaultDependencies;
assert trial.systemd.user.targets.niri-session.after == [ "niri.service" ];
assert builtins.elem "niri-session.target" trial.systemd.user.services.niri.wants;
assert
  trial.systemd.user.services.polkit-gnome-authentication-agent-1.partOf
  == [ "graphical-session.target" ];
assert trial.services.gnome.gnome-keyring.enable == baseline.services.gnome.gnome-keyring.enable;
assert trial.security.pam.services.swaylock.text == baseline.security.pam.services.swaylock.text;
assert niri.greetd.autoLogin == baseline.modules.wm.niri.greetd.autoLogin;
assert greeter.initial_session.user == baseline.services.greetd.settings.initial_session.user;
assert niri.greetd.sessionExecutable == "niri-session";
assert greeter.initial_session.command == "${niri.greetd.sessionPackage}/bin/niri-session";
assert !actual.modules.wm.niri.greetd.autoLogin.enable;
assert !(actual.services.greetd.settings ? initial_session);
assert !(passwordLogin.services.greetd.settings ? initial_session);
assert
  passwordLogin.services.greetd.settings.default_session
  == primary.services.greetd.settings.default_session;
assert actual.security.pam.services.login.enableGnomeKeyring;
assert lib.hasInfix "auth substack login" actual.security.pam.services.greetd.text;
assert lib.hasInfix "session include login" actual.security.pam.services.greetd.text;
assert primary.modules.wm.niri.greetd.sessionExecutable == "umbriel-trial-session";
assert builtins.length primary.modules.wm.niri.greetd.extraSessionPackages == 1;
assert
  primary.modules.wm.niri.greetd.sessionPackage == builtins.head niri.greetd.extraSessionPackages;
assert
  builtins.head primary.modules.wm.niri.greetd.extraSessionPackages == niri.greetd.sessionPackage;
assert
  primary.services.greetd.settings.initial_session.command
  == "${primary.modules.wm.niri.greetd.sessionPackage}/bin/umbriel-trial-session";
assert primary.services.greetd.settings.initial_session.user == greeter.initial_session.user;
assert
  primary.services.greetd.settings.default_session.command
  == "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --sessions ${primary.modules.wm.niri.greetd.sessionPackage}/share/wayland-sessions:${niri.greetd.sessionPackage}/share/wayland-sessions";
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
assert !(home.systemd.user.services ? noctalia);
assert home.${namespace}.wm.niri.isolateShellServices;
assert lib.all
  (
    name:
    let
      service = home.systemd.user.services.${name};
    in
    service.Unit.ConditionEnvironment == "XDG_CURRENT_DESKTOP=niri"
    && service.Unit.PartOf == [ "niri-session.target" ]
    && !(service.Unit ? BindsTo)
    &&
      service.Unit.Requisite == [
        "niri.service"
        "niri-session.target"
      ]
    && lib.all (name: lib.elem name service.Unit.After) [
      "niri.service"
      "niri-session.target"
    ]
    && service.Install.WantedBy == [ "niri-session.target" ]
  )
  [
    "waybar"
    "mako"
    "niri-awww"
    "niri-wallpaper"
    "niri-cliphist-text"
    "niri-cliphist-image"
    "fcitx5-niri"
  ];
assert home.systemd.user.services.mako.Service.BusName == "org.freedesktop.Notifications";
assert lib.hasInfix "Hidden=true" home.xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".text;
pkgs.runCommand "umbriel-session-wiring" { nativeBuildInputs = [ pkgs.python3 ]; } ''
  # Production-boundary fixtures inject every process call. No real compositor,
  # portal, environment import, lock screen or power action is executed.
  python3 -B ${./test-session.py} ${../../modules/nixos/wm/umbriel/session.py}
  python3 -B ${./test-ipc.py} ${../../modules/home/wm/umbriel/ipc.py}
  echo 'Declared wiring and boundary fixtures passed; live session UAT unverified.' > "$out"
''
