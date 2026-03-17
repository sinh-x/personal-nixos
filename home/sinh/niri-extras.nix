# Shared niri extras for sinh — workspaces, window rules, and keybinds
_: {
  sinh-x.wm.niri = {
    extraWorkspaces = ''
      // External monitor (ext-) - auto-assigned to external display at startup
      // via workspace_monitors script (no hardcoded output binding)
      workspace "ext-term" {}
      workspace "ext-browser" {}
      workspace "ext-code" {}
    '';

    extraWindowRules = "";

    extraKeybinds = ''
      // Run as Root - Execute commands with elevated privileges
      Mod+R hotkey-overlay-title="Run as Root" { spawn "bash" "-c" "~/.config/niri/scripts/rofi_asroot"; }

      // Named workspaces - External monitor
      Mod+6 hotkey-overlay-title="Ext: Terminal" { focus-workspace "ext-term"; }
      Mod+7 hotkey-overlay-title="Ext: Browser" { focus-workspace "ext-browser"; }
      Mod+8 hotkey-overlay-title="Ext: Code" { focus-workspace "ext-code"; }

      // Move window to workspace - External monitor
      Mod+Shift+6 { move-column-to-workspace "ext-term"; }
      Mod+Shift+7 { move-column-to-workspace "ext-browser"; }
      Mod+Shift+8 { move-column-to-workspace "ext-code"; }
    '';
  };
}
