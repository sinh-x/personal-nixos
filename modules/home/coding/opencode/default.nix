{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.coding.opencode;
in
{
  options.${namespace}.coding.opencode = {
    enable = mkEnableOption "OpenCode AI coding agent";
    plugins = {
      enable = mkEnableOption "OpenCode plugins and config files";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        opencode
      ];
    })
    (mkIf cfg.plugins.enable {
      home.file = {
        ".config/opencode/opencode.json".text = builtins.readFile ./config/opencode.json;
        ".config/opencode/plugins/git-context.tsx".text =
          builtins.readFile ./config/plugins/git-context.tsx;
        ".config/opencode/plugins/pa-safety-activity.js".text =
          builtins.readFile ./config/plugins/pa-safety-activity.js;
        ".config/opencode/themes/mytheme.json".text = builtins.readFile ./config/themes/mytheme.json;
      };
    })
  ];
}
