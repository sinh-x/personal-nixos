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
          modules.wm.umbriel.enable = true;
          home-manager.users.sinh.${namespace}.wm.umbriel.enable = true;
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
    ${../../home/sinh/niri-extras.nix} ${../../home/sinh/Drgnfly.nix} diagnostics.json
  test -e ${inputs.self.checks.${pkgs.stdenv.hostPlatform.system}.umbriel-session-wiring}
  mkdir "$out"
  cp diagnostics.json "$out/config-diagnostics.json"
  echo '112 source triggers, 110 accepted target chords, 17 rule dispositions, 8 workspaces; runtime parity unverified.' > "$out/summary"
''
