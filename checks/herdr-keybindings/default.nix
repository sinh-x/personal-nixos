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

  expectedActionRoutes = {
    focus_pane_down = [
      "prefix+down"
      "prefix+j"
    ];
    focus_pane_left = [
      "prefix+h"
      "prefix+left"
    ];
    focus_pane_right = [
      "prefix+l"
      "prefix+right"
    ];
    focus_pane_up = [
      "prefix+k"
      "prefix+up"
    ];
    next_tab = [
      "alt+shift+right"
      "prefix+n"
    ];
    next_workspace = [ "alt+shift+down" ];
    previous_tab = [
      "alt+shift+left"
      "prefix+p"
    ];
    previous_workspace = [ "alt+shift+up" ];
    switch_workspace = map (index: "prefix+${toString index}") (lib.range 1 9);
  };
  exactRouteSetViolations = lib.concatLists (
    lib.mapAttrsToList (
      action: expectedRoutes:
      let
        actualRoutes = actionBindings.${action} or [ ];
      in
      lib.optional (sorted actualRoutes != sorted expectedRoutes)
        "${action}: expected [${lib.concatStringsSep ", " expectedRoutes}], got [${lib.concatStringsSep ", " actualRoutes}]"
    ) expectedActionRoutes
  );

  routeOwners =
    route:
    lib.attrNames (lib.filterAttrs (_action: routes: lib.elem route routes) actionBindings)
    ++ lib.optional (lib.any (binding: binding.key == route) commandBindings) "command";
  routeOwnershipViolations = lib.concatLists (
    lib.mapAttrsToList (
      action: routes:
      map (
        route: "${route}: expected owner ${action}, got [${lib.concatStringsSep ", " (routeOwners route)}]"
      ) (lib.filter (route: routeOwners route != [ action ]) routes)
    ) expectedActionRoutes
  );

  sequentialWorkspacePrefixExceptions = [
    "next_workspace"
    "previous_workspace"
  ];
  requiredPrefixedActions = [
    "focus_agent"
    "focus_pane_down"
    "focus_pane_left"
    "focus_pane_right"
    "focus_pane_up"
    "new_tab"
    "next_tab"
    "previous_tab"
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
  exactRouteSetViolations == [ ]
) "Herdr action route sets differ: ${lib.concatStringsSep "; " exactRouteSetViolations}";
assert lib.assertMsg (routeOwnershipViolations == [ ])
  "Herdr routes have incorrect or duplicate owners: ${lib.concatStringsSep "; " routeOwnershipViolations}";
assert lib.assertMsg (
  missingPrefixedActions == [ ]
) "Herdr actions are missing prefix routes: ${lib.concatStringsSep ", " missingPrefixedActions}";
assert lib.assertMsg
  (sorted configuredActionsWithoutPrefix == sorted sequentialWorkspacePrefixExceptions)
  "Only previous_workspace and next_workspace may lack prefix routes; got: ${lib.concatStringsSep ", " configuredActionsWithoutPrefix}";
assert lib.assertMsg (
  commandsWithoutPrefix == [ ]
) "Configured Herdr commands must use prefix routes";
assert lib.assertMsg hasPrefixedAgentPicker "Herdr agent picker must retain prefix+a";
pkgs.runCommand "herdr-keybindings" { } ''
  touch "$out"
''
