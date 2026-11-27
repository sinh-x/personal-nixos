{
  lib,
  adapter,
  homeDirectory,
}:
let
  command = args: "spawn ${adapter}/bin/umbriel-trial ${args}";
  script = name: "spawn ${lib.escapeShellArg "${homeDirectory}/.config/niri/scripts/${name}"}";
  actions = {
    "Mod+Return" = command "spawn terminal";
    "Mod+T" = command "spawn terminal";
    "Mod+O" = "overview-toggle";
    "Alt+F1" = "spawn noctalia msg panel-toggle launcher";
    "Alt+F2" = script "rofi_runner";
    "Mod+N" = script "rofi_network";
    "Mod+B" = script "rofi_bluetooth";
    "Mod+X" = "spawn umbriel-controls power-menu";
    "Mod+A" = "spawn umbriel-capture menu";
    "Mod+E" = "spawn thunar";
    "Mod+Shift+W" = command "spawn browser";
    "Ctrl+Alt+W" = command "select all";
    "Ctrl+Alt+T" = command "select ghostty";
    "Ctrl+Alt+B" = command "select browser";
    "Mod+Ctrl+W" = "spawn noctalia msg panel-toggle wallpaper";
    "Mod+C" = "window-close";
    "Mod+F" = "window-toggle-maximize";
    "Mod+Shift+F" = "window-toggle-fullscreen";
    "Mod+Space" = "window-toggle-floating";
    "Mod+Shift+Space" = "window-focus-switch-floating";
    "Mod+Left" = "window-focus-left";
    "Mod+Right" = "window-focus-right";
    "Mod+Up" = "window-focus-up";
    "Mod+Down" = "window-focus-down";
    "Mod+H" = "window-focus-left";
    "Mod+L" = "window-focus-right";
    "Mod+J" = "window-focus-down";
    "Mod+K" = "window-focus-up";
    "Mod+Shift+Left" = "column-move-left";
    "Mod+Shift+Right" = "column-move-right";
    "Mod+Shift+Up" = "window-move-up";
    "Mod+Shift+Down" = "window-move-down";
    "Mod+Shift+H" = "column-move-left";
    "Mod+Shift+L" = "column-move-right";
    "Mod+Shift+J" = "window-move-down";
    "Mod+Shift+K" = "window-move-up";
    "Mod+Ctrl+Left" = "window-modify-primary-extent -0.1";
    "Mod+Ctrl+Right" = "window-modify-primary-extent 0.1";
    "Mod+Ctrl+Up" = "window-modify-secondary-extent -0.1";
    "Mod+Ctrl+Down" = "window-modify-secondary-extent 0.1";
    "Mod+Ctrl+H" = "window-modify-primary-extent -0.1";
    "Mod+Ctrl+L" = "window-modify-primary-extent 0.1";
    "Mod+Ctrl+J" = "window-modify-secondary-extent 0.1";
    "Mod+Ctrl+K" = "window-modify-secondary-extent -0.1";
    "Mod+Minus" = "window-modify-primary-extent -0.1";
    "Mod+Equal" = "window-modify-primary-extent 0.1";
    "Mod+W" = "window-cycle-primary-extent";
    "Mod+BracketLeft" = "window-consume-from-right";
    "Mod+BracketRight" = command "expel";
    "Mod+Ctrl+BracketLeft" = "window-consume-or-expel-left";
    "Mod+Ctrl+BracketRight" = "window-consume-or-expel-right";
    "Mod+Tab" = command "tab next";
    "Mod+Shift+Tab" = command "tab previous";
    "Ctrl+Alt+Up" = "workspace-previous";
    "Ctrl+Alt+Down" = "workspace-next";
    "Ctrl+Alt+Shift+Up" = "column-move-to-workspace-previous";
    "Ctrl+Alt+Shift+Down" = "column-move-to-workspace-next";
    "Mod+Comma" = "output-focus-left";
    "Mod+Period" = "output-focus-right";
    "Mod+Shift+Comma" = "column-move-to-output-left";
    "Mod+Shift+Period" = "column-move-to-output-right";
    "Mod+Ctrl+Shift+Left" = "column-move-to-output-left";
    "Mod+Ctrl+Shift+Right" = "column-move-to-output-right";
    "Mod+Ctrl+Comma" = "workspace-move-to-output-left";
    "Mod+Ctrl+Period" = "workspace-move-to-output-right";
    "Mod+Slash" = "cheatsheet-toggle";
    "Print" = "spawn umbriel-capture region";
    "Mod+Print" = "spawn umbriel-capture region";
    "Ctrl+Print" = "spawn umbriel-capture window";
    "Shift+Print" = "spawn umbriel-capture screen";
    "Mod+S" = "spawn umbriel-capture record-menu";
    "Mod+Shift+S" = "spawn umbriel-capture record-toggle";
    "XF86AudioRaiseVolume" = "spawn umbriel-controls volume-up";
    "XF86AudioLowerVolume" = "spawn umbriel-controls volume-down";
    "XF86AudioMute" = "spawn umbriel-controls volume-mute";
    "XF86AudioMicMute" = "spawn umbriel-controls mic-mute";
    "XF86MonBrightnessUp" = "spawn umbriel-controls brightness-up";
    "XF86MonBrightnessDown" = "spawn umbriel-controls brightness-down";
    "XF86AudioNext" = "spawn mpc next";
    "XF86AudioPrev" = "spawn mpc prev";
    "XF86AudioPlay" = "spawn mpc toggle";
    "XF86AudioStop" = "spawn mpc stop";
    "Mod+P" = "spawn noctalia msg color-pick";
    "Ctrl+Grave" = "spawn noctalia msg panel-toggle clipboard";
    # Exact trial-only difference approved in the d-74af86 foreground question.
    "Mod+I" = "spawn noctalia msg notification-clear-active";
    "Mod+Shift+I" = "spawn noctalia msg notification-clear-active";
    "Ctrl+Alt+Delete" = "session-quit";
    "Mod+Shift+P" = "spawn umbriel-controls power-menu";
    "Mod+WheelScrollDown" = "workspace-next";
    "Mod+WheelScrollUp" = "workspace-previous";
    "Mod+Shift+WheelScrollDown" = "column-move-to-workspace-next";
    "Mod+Shift+WheelScrollUp" = "column-move-to-workspace-previous";
    # These are retained as separate source ledger entries. The two duplicate
    # targets and their 150 ms cooldown are the explicitly accepted deviation.
    "Mod+TouchpadScrollDown" = "workspace-next";
    "Mod+TouchpadScrollUp" = "workspace-previous";
    "Mod+R" = script "rofi_asroot";
    "Mod+M" = script "rofi_music";
  }
  // builtins.listToAttrs (
    lib.concatMap (
      index:
      let
        name = builtins.elemAt names (index - 1);
      in
      [
        {
          name = "Mod+${toString index}";
          value = command "focus ${name}";
        }
        {
          name = "Mod+Shift+${toString index}";
          value = command "move ${name}";
        }
      ]
    ) (lib.range 1 8)
  );
  names = [
    "main-term"
    "main-browser"
    "main-code"
    "chat"
    "email"
    "ext-term"
    "ext-browser"
    "ext-code"
  ];
in
lib.mapAttrsToList (source: action: {
  inherit source;
  target = lib.replaceStrings [ "WheelScroll" "TouchpadScroll" ] [ "Wheel" "Wheel" ] source;
  binding = {
    inherit action;
  }
  // lib.optionalAttrs (lib.hasPrefix "XF86" source) { allow_when_locked = true; }
  // lib.optionalAttrs (lib.hasInfix "Scroll" source) { cooldown_ms = 150; };
}) actions
