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

## Implementation

- Binding: `modules/home/wm/niri/niri_config/config.kdl`.
- Executable: `modules/home/wm/niri/niri_config/scripts/rofi-browser-switcher`.
- Shared theme: `modules/home/wm/niri/niri_config/rofi/ghostty_switcher.rasi` (unchanged).
- Home Manager's existing recursive script/theme deployment installs both assets; no additional package or module option is needed.

Application IDs are compared case-insensitively against this exact allowlist:

| Browser | Application IDs |
| --- | --- |
| Vivaldi | `vivaldi`, `vivaldi-stable` |
| Zen | `zen`, `zen-twilight` |
| Google Chrome | `google-chrome`, `google-chrome-stable`, `com.google.Chrome` |

The installed desktop entries identify `vivaldi`, `zen-twilight`, and `google-chrome` as their startup classes. This is supporting package metadata, not observation of live Niri windows. Custom `--class`/`--name` overrides, standalone web apps, and other channel IDs outside the allowlist are not matched. No broad prefix or title matching is used.

The picker preserves Niri's snapshot order. Each Rofi index maps to a separately captured window ID. A window closed before selection can make the focus request fail; that failure is returned without retrying or launching a replacement. Cancellation and invalid indices are no-ops; IPC errors produce a generic diagnostic without logging titles.

## Automated validation

Run the isolated regression suite from the repository root:

```sh
python3 -B checks/niri-browser-picker/test-browser-picker.py \
  --script modules/home/wm/niri/niri_config/scripts/rofi-browser-switcher \
  --config modules/home/wm/niri/niri_config/config.kdl \
  --theme modules/home/wm/niri/niri_config/rofi/ghostty_switcher.rasi \
  --verbose
```

The focused flake check also runs Bash syntax and ShellCheck, checks disabled/enabled Home Manager behavior, exercises the deployed script tree, and validates the rendered KDL with `niri validate`:

```sh
nix build --no-write-lock-file --no-link --print-build-logs \
  .#checks.x86_64-linux.niri-browser-picker
```

The 15 regression tests cover browser aliases, exclusion of unrelated apps and title matches, duplicate titles, cross-workspace IDs, profile/private titles, missing metadata, unsafe title characters, invalid IDs, cancellation, invalid indices, IPC failures, disappearing windows, and the three keyboard bindings. Mocks run with an isolated command path and no inherited desktop connection variables.

## Operator UAT

Only Sinh may activate the configuration. If a temporary test activation is desired, run manually:

```sh
sudo sys test
```

Then check the actual Niri desktop:

1. Open Vivaldi, Zen, and Chrome windows, including two with identical titles, another profile/private window, and a window on another workspace or monitor. Include a Ghostty window and an excluded browser such as Edge.
2. Press `Ctrl+Alt+B`. Confirm the centered Ghostty-style filter appears, with only supported browser windows and a browser/title label for every row. Type part of a title, select a filtered result, and verify the exact target window receives focus across workspaces/monitors.
3. Select each duplicate-title window independently. Check that profile/private windows are offered without claiming inferred profile labels.
4. Cancel with Escape and verify focus is unchanged. With no supported browser windows open, confirm the shortcut neither launches a browser nor leaves a menu open.
5. Press `Ctrl+Alt+T` and `Ctrl+Alt+W` and confirm their previous behavior is unchanged. Check `Browser Switcher` appears in Niri's hotkey overlay.

If an expected browser is missing, inspect its application ID locally; do not publish full IPC output or private window titles. An unmatched custom ID requires an explicit allowlist decision, not a title heuristic.

Record the observed results separately. A persistent switch, if desired after successful UAT, remains Sinh's manual `sudo sys rebuild` operation. Neither activation nor interactive UAT is performed by the automated check.

## Validation boundary

Automated checks use synthetic window metadata and mocked Niri/Rofi commands, never the operator's live windows. Focused script lint, binding assertions, and an isolated flake check verify the implementation without a system build or dependency update.

Interactive keyboard behavior, browser application IDs on the actual desktop, theme appearance, and cross-workspace focus require operator UAT after activation. Automated results do not establish human acceptance. Agents must not activate the configuration or execute privileged commands.
