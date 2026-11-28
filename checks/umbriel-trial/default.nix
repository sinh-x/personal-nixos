{
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  trial =
    (inputs.self.nixosConfigurations.Drgnfly.extendModules {
      modules = [
        {
          modules.wm.umbriel.enable = lib.mkForce true;
          home-manager.users.sinh.${namespace}.wm.umbriel.enable = lib.mkForce true;
        }
      ];
    }).config;
  home = trial.home-manager.users.sinh;
  desktop = import ../../modules/home/wm/umbriel/settings.nix {
    inherit lib;
    adapter = "/fixture";
    homeDirectory = "/home/sinh";
    primary = "eDP-1";
  };
  manifest = pkgs.writeText "umbriel-source-ledger.json" (
    builtins.toJSON {
      inherit (desktop) bindings ruleLedger;
    }
  );
in
pkgs.runCommand "umbriel-trial" { nativeBuildInputs = [ pkgs.python3 ]; } ''
  # Consume the same rendered configuration Home Manager would install, using
  # the actual pinned parser. This command never starts a compositor.
  if ! ${trial.programs.umbriel.package}/bin/umbriel config validate \
    -c ${home.xdg.configFile."umbriel/config.toml".source} --json > diagnostics.json; then
    python3 -c 'from pathlib import Path; print(Path("diagnostics.json").read_text())'
    exit 1
  fi
  python3 -B ${./test-parity.py} \
    ${home.xdg.configFile."umbriel/config.toml".source} ${manifest} \
    ${../../modules/home/wm/niri/niri_config/config.kdl} \
    ${../../home/sinh/niri-extras.nix} ${../../home/sinh/Drgnfly.nix} diagnostics.json \
    ${home.xdg.configFile."noctalia/config.toml".source} \
    ${home.home.file.".config/niri/config.kdl".source} \
    ${../../modules/home/wm/niri/niri_config/scripts/startup_apps}
  # Check the assembled Home Manager product, not just option declarations.
  test ! -e ${home.home.path}/bin/logseq
  cmp ${home.home.activationPackage}/home-files/.config/niri/scripts/startup_apps \
    ${../../modules/home/wm/niri/niri_config/scripts/startup_apps}
  test "$(readlink -f ${home.home.activationPackage}/home-files/.config/niri/scripts/workspace_monitors)" = \
    "${home.home.file.".config/niri/scripts/workspace_monitors".source}"
  test "$(readlink -f ${home.home.activationPackage}/home-files/.config/niri/config.kdl)" = \
    "${home.home.file.".config/niri/config.kdl".source}"
  test "$(readlink -f ${home.home.activationPackage}/home-files/.config/noctalia/config.toml)" = \
    "${home.xdg.configFile."noctalia/config.toml".source}"
  test "$(readlink -f ${home.home.activationPackage}/home-files/.config/autostart/org.fcitx.Fcitx5.desktop)" = \
    "${home.xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".source}"
  ${trial.programs.niri.package}/bin/niri validate --config ${
    home.home.file.".config/niri/config.kdl".source
  }
  python3 -B ${./test-controls.py} ${../../modules/home/wm/umbriel}
  # swaylock 1.8.6 deliberately returns 1 for help; bind the known interface
  # and version instead of treating this as a live-lock or readiness test.
  python3 -c 'import subprocess,sys; r=subprocess.run([sys.argv[1], "--help"], capture_output=True, text=True); text=r.stdout+r.stderr; assert r.returncode == 1 and "Usage: swaylock" in text and "--ready-fd" in text; v=subprocess.check_output([sys.argv[1], "--version"], text=True); assert v.strip() == "swaylock version 1.8.6"' ${pkgs.swaylock}/bin/swaylock
  test -e ${inputs.self.checks.${pkgs.stdenv.hostPlatform.system}.umbriel-session-wiring}
  mkdir "$out"
  cp diagnostics.json "$out/config-diagnostics.json"
  echo '112 source triggers, 110 accepted target chords, 17 rule dispositions, 8 workspaces; P3 negative fixtures and native configs checked; real capture/power/runtime parity unverified.' > "$out/summary"
''
