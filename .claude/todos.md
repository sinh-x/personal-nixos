# TODOs

## 1. Add dynamic zellij session completion to zsh config

- **Added**: 2026-02-09T07:14:50+07:00
- **By**: Sinh Nguyen
- **Status**: completed
- **Completed**: 2026-02-10
- **Context**: UX improvement - Would be more convenient to tab-complete session names instead of typing them. Currently the static completion file doesn't call `zellij list-sessions` for real-time session names.

---

## 2. Setup system python which would allow skills run smoothly

- **Added**: 2026-02-09T07:18:55+07:00
- **By**: Sinh Nguyen
- **Status**: completed
- **Completed**: 2026-02-10
- **Context**: Skills require python3 - Skills like skill-creator use python scripts that fail when python3 isn't in PATH. Need to configure NixOS/home-manager to make python3 globally available.
- **Resolution**: Added python3 to cli-apps/utilities module.

---

## 3. Update git command aliases based on fish config

- **Added**: 2026-02-09T13:42:00+07:00
- **By**: Sinh Nguyen
- **Status**: completed
- **Completed**: 2026-02-10
- **Context**: UX improvement - Add familiar git shortcuts to NixOS/home-manager config based on fish shell aliases (e.g., gp=git pull, gs=git status, etc.) for consistent experience across shells.
- **Resolution**: Already present in zsh config (lines 151-171) matching fish config.

---

## 4. Add zsh integration with z for directory jumping

- **Added**: 2026-02-09T20:45:00+07:00
- **By**: Sinh Nguyen
- **Status**: completed
- **Completed**: 2026-02-10
- **Context**: CLI usability - Enable easy folder navigation using z (zoxide or similar) to quickly jump to frequently used directories.
- **Resolution**: Already present in cli-apps/utilities with `enableZshIntegration = true`.

---

## 5. Add color picker support for Niri

- **Added**: 2026-02-09T21:15:00+07:00
- **By**: Sinh Nguyen
- **Status**: completed
- **Completed**: 2026-02-10
- **Context**: Quick note - Need color picker functionality in Niri window manager. The colorpicker script exists but hyprpicker package is missing from niri module packages.
- **Resolution**: Added hyprpicker to niri module packages.

---
