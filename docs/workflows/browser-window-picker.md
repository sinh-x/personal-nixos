# Niri browser-window picker

Ownership: NX-076 browser-window selection, scope, and validation.

## Scope

`Ctrl+Alt+B` lists existing Vivaldi, Zen, and Google Chrome windows across the current Niri session, then focuses the selected window. It does not launch browsers or list individual tabs.

All profiles and private/incognito windows are included when they use a supported application ID. Browser name and window title identify each row; profile names are not inferred. The picker reads only Niri's window metadata, never browser profile files. Edge, Brave, Firefox, and other applications are outside this ticket's selected scope, even if installed.

The interaction follows the existing `Ctrl+Alt+T` Ghostty picker: a centered, searchable Rofi dmenu using the same theme. `Ctrl+Alt+T` continues to select Ghostty windows, and `Ctrl+Alt+W` retains the existing general window switcher.

## Acceptance criteria

1. `Ctrl+Alt+B` offers only the supported browsers' existing windows, including windows on other workspaces and monitors.
2. Each numbered row shows its browser and title. Choosing a row focuses its captured Niri window ID, not a title match. Duplicate titles remain independently selectable.
3. Cancelling or having no matching windows performs no focus action and starts no browser.
4. Missing titles have a fallback; title control characters cannot create extra rows or corrupt the ID mapping. Unavailable/malformed IPC and invalid selections fail closed.
5. The Ghostty script, its theme, and the `Ctrl+Alt+T/W` bindings remain unchanged.

## Validation boundary

Automated checks use synthetic window metadata and mocked Niri/Rofi commands, never the operator's live windows. Focused script lint, binding assertions, and an isolated flake check verify the implementation without a system build or dependency update.

Interactive keyboard behavior, browser application IDs on the actual desktop, theme appearance, and cross-workspace focus require operator UAT after activation. Automated results do not establish human acceptance. Agents must not activate the configuration or execute privileged commands.
