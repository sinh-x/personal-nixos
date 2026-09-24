{
  lib,
  pkgs,
  ...
}:
let
  config = builtins.fromTOML (builtins.readFile ../../modules/home/cli-apps/herdr/config.toml);
  inherit (config) keys;

  actionBindings = builtins.removeAttrs keys [
    "command"
    "prefix"
  ];
  commandBindings = keys.command or [ ];
  allBindings = lib.concatLists (
    (builtins.attrValues actionBindings) ++ [ (map (binding: binding.key) commandBindings) ]
  );

  routeParts = route: lib.splitString "+" route;
  isPrefixed = route: lib.elem "prefix" (routeParts route);
  isDirectAlt = route: !isPrefixed route && lib.elem "alt" (routeParts route);
  isDirectCtrlAlt =
    route: !isPrefixed route && lib.elem "ctrl" (routeParts route) && lib.elem "alt" (routeParts route);

  approvedDirectAltBindings = [
    "alt+shift+down"
    "alt+shift+left"
    "alt+shift+right"
    "alt+shift+up"
  ];
  directAltBindings = lib.filter isDirectAlt allBindings;
  directCtrlAltBindings = lib.filter isDirectCtrlAlt allBindings;
  sorted = lib.sort builtins.lessThan;

  requiredRoutes = {
    next_tab = [
      "alt+shift+right"
      "prefix+n"
      "prefix+right"
    ];
    next_workspace = [
      "alt+shift+down"
      "prefix+down"
    ];
    previous_tab = [
      "alt+shift+left"
      "prefix+left"
      "prefix+p"
    ];
    previous_workspace = [
      "alt+shift+up"
      "prefix+up"
    ];
    switch_workspace = map (index: "prefix+${toString index}") (lib.range 1 9);
  };
  missingRequiredRoutes = lib.concatLists (
    lib.mapAttrsToList (
      action: routes:
      map (route: "${action}:${route}") (
        lib.filter (route: !(lib.elem route (actionBindings.${action} or [ ]))) routes
      )
    ) requiredRoutes
  );

  requiredPrefixedActions = [
    "focus_agent"
    "focus_pane_down"
    "focus_pane_left"
    "focus_pane_right"
    "focus_pane_up"
    "new_tab"
    "next_tab"
    "next_workspace"
    "previous_tab"
    "previous_workspace"
    "split_vertical"
    "switch_workspace"
    "workspace_picker"
    "zoom"
  ];
  missingPrefixedActions = lib.filter (
    action: !(lib.any isPrefixed (actionBindings.${action} or [ ]))
  ) requiredPrefixedActions;
  configuredActionsWithoutPrefix = lib.attrNames (
    lib.filterAttrs (_action: routes: !(lib.any isPrefixed routes)) actionBindings
  );
  commandsWithoutPrefix = lib.filter (binding: !isPrefixed binding.key) commandBindings;
  hasPrefixedAgentPicker = lib.any (
    binding: binding.type == "pane" && binding.key == "prefix+a"
  ) commandBindings;
in
assert lib.assertMsg (keys.prefix == "ctrl+b") "Herdr prefix must remain ctrl+b";
assert lib.assertMsg (
  sorted directAltBindings == sorted approvedDirectAltBindings
) "Herdr direct Alt bindings must be exactly alt+shift+left/right/up/down";
assert lib.assertMsg (
  directCtrlAltBindings == [ ]
) "Herdr must not define direct Ctrl+Alt bindings";
assert lib.assertMsg (
  missingRequiredRoutes == [ ]
) "Herdr is missing required routes: ${lib.concatStringsSep ", " missingRequiredRoutes}";
assert lib.assertMsg (
  missingPrefixedActions == [ ]
) "Herdr actions are missing prefix routes: ${lib.concatStringsSep ", " missingPrefixedActions}";
assert lib.assertMsg (configuredActionsWithoutPrefix == [ ])
  "Configured Herdr actions are missing prefix routes: ${lib.concatStringsSep ", " configuredActionsWithoutPrefix}";
assert lib.assertMsg (
  commandsWithoutPrefix == [ ]
) "Configured Herdr commands must use prefix routes";
assert lib.assertMsg hasPrefixedAgentPicker "Herdr agent picker must retain prefix+a";
pkgs.runCommand "herdr-keybindings" { } ''
  touch "$out"
''
