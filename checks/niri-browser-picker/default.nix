{
  inputs,
  namespace,
  pkgs,
  ...
}:
let
  mkHome =
    enable:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit namespace; };
      modules = [
        ../../modules/home/wm/niri
        {
          home = {
            username = "sinh";
            homeDirectory = "/home/sinh";
            stateVersion = "24.11";
          };
          ${namespace}.wm.niri = {
            inherit enable;
            monitors.primary = "NX076-SYNTHETIC-OUTPUT";
          };
        }
      ];
    };
  disabled = (mkHome false).config;
  enabled = (mkHome true).config;
  scripts = enabled.home.file.".config/niri/scripts";
  theme = enabled.home.file.".config/niri/rofi";
  configFile = enabled.home.file.".config/niri/config.kdl";
in
assert !(disabled.home.file ? ".config/niri/scripts");
assert !(disabled.home.file ? ".config/niri/config.kdl");
assert scripts.recursive;
assert theme.recursive;
pkgs.runCommand "niri-browser-picker"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.jq
      pkgs.niri
      pkgs.python3
      pkgs.shellcheck
    ];
  }
  ''
    script=${scripts.source}/rofi-browser-switcher
    bash -n "$script"
    shellcheck "$script"
    python3 -B ${./test-browser-picker.py} \
      --script "$script" \
      --config ${configFile.source} \
      --theme ${theme.source}/ghostty_switcher.rasi \
      --verbose

    # Parse Home Manager's rendered config, without connecting to a session.
    niri validate --config ${configFile.source}
    touch "$out"
  ''
