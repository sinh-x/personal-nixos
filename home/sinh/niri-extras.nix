# Shared niri extras for sinh — workspaces, window rules, and keybinds
# that were previously hardcoded in config.kdl
_: {
  sinh-x.wm.niri = {
    extraWorkspaces = ''
      workspace "chat" {
          open-on-output "@PRIMARY_OUTPUT@"
      }
      workspace "email" {
          open-on-output "@PRIMARY_OUTPUT@"
      }

      // External monitor (ext-) - auto-assigned to external display at startup
      // via workspace_monitors script (no hardcoded output binding)
      workspace "ext-term" {}
      workspace "ext-browser" {}
      workspace "ext-code" {}
    '';

    extraWindowRules = ''
      // Zoom -> all windows on "email" workspace
      window-rule {
          match app-id=r#"(?i)zoom"#
          open-on-workspace "email"
      }

      // Zoom popups/dialogs -> floating
      window-rule {
          match app-id=r#"(?i)zoom"#
          match title=r#"(?i)(settings|participants|chat|share|invite)"#
          open-floating true
      }

      // Zoom main meeting window -> maximized and focused
      window-rule {
          match app-id=r#"(?i)zoom"#
          match title=r#"(?i)(meeting|zoom)"#
          open-maximized true
          open-focused true
      }

      // Chat apps -> open on "chat" workspace without stealing focus
      window-rule {
          match app-id="discord"
          match app-id="signal"
          match app-id="org.telegram.desktop"
          match app-id="ViberPC"
          open-on-workspace "chat"
          open-maximized true
          open-maximized-to-edges false
          open-fullscreen false
          open-focused false
      }

      // Code editors -> open on "main-code" workspace
      window-rule {
          match app-id=r#"(?i)code"#
          match app-id=r#"(?i)vscode"#
          open-on-workspace "main-code"
      }

      // Email & productivity apps -> open on "email" workspace without stealing focus
      window-rule {
          match app-id="superProductivity"
          match app-id="anytype"
          open-on-workspace "email"
          open-focused false
      }

      // Telegram Media viewer -> floating, centered, 1/3 screen size
      window-rule {
          match app-id=r#"^org\.telegram\.desktop$"# title="^Media viewer$"
          open-floating true
          open-fullscreen false
          open-focused true
          default-column-width { proportion 0.33333; }
          default-window-height { proportion 0.33333; }
          default-floating-position x=0 y=355 relative-to="top"
      }
    '';

    extraKeybinds = ''
      // Run as Root - Execute commands with elevated privileges
      Mod+R hotkey-overlay-title="Run as Root" { spawn "bash" "-c" "~/.config/niri/scripts/rofi_asroot"; }
      // Music Player - Control MPD music playback
      Mod+M hotkey-overlay-title="Music Player" { spawn "bash" "-c" "~/.config/niri/scripts/rofi_music"; }

      // Named workspaces - Chat & Email
      Mod+4 hotkey-overlay-title="Chat" { focus-workspace "chat"; }
      Mod+5 hotkey-overlay-title="Email" { focus-workspace "email"; }

      // Named workspaces - External monitor
      Mod+6 hotkey-overlay-title="Ext: Terminal" { focus-workspace "ext-term"; }
      Mod+7 hotkey-overlay-title="Ext: Browser" { focus-workspace "ext-browser"; }
      Mod+8 hotkey-overlay-title="Ext: Code" { focus-workspace "ext-code"; }

      // Move window to workspace - Chat & Email
      Mod+Shift+4 { move-column-to-workspace "chat"; }
      Mod+Shift+5 { move-column-to-workspace "email"; }

      // Move window to workspace - External monitor
      Mod+Shift+6 { move-column-to-workspace "ext-term"; }
      Mod+Shift+7 { move-column-to-workspace "ext-browser"; }
      Mod+Shift+8 { move-column-to-workspace "ext-code"; }
    '';
  };
}
