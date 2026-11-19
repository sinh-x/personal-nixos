# Ghostty canvas consistency

The shared Ghostty module uses an opaque `#1c1c2b` canvas to preserve the preferred fullscreen appearance in normal windows. Transparency is deliberately disabled so wallpaper and fullscreen compositing cannot tint the canvas differently. The Catppuccin Mocha foreground, ANSI palette, cursor and selection colors are unchanged.

## Configuration ownership

- `modules/home/cli-apps/ghostty/default.nix` owns the shared background and opacity, enabled by Drgnfly, FireFly and Lily.
- `modules/home/wm/niri/niri_config/scripts/ghostty` inherits those settings, including its separate `-F` fullscreen launch path. That path retains its existing font and padding overrides; normal windows do not acquire them.
- `modules/home/cli-apps/herdr/config.toml` retains the tokyo-night UI theme. A blank Herdr terminal pane follows the Ghostty canvas; intentional sidebar, tab and focus accents need not match the canvas.

Do not repair appearance by editing deployed Home Manager files, refreshing dependencies, replacing the full palette or remapping shortcuts. Ghostty's existing default Ctrl+Enter binding toggles fullscreen; Niri's fullscreen action and Herdr's prefix+z pane zoom are separate interactions.

## Focused source checks

With repository tooling available, run from the reviewed checkout:

```bash
nix-instantiate --parse modules/home/cli-apps/ghostty/default.nix >/dev/null
nixfmt --check modules/home/cli-apps/ghostty/default.nix
bash -n modules/home/wm/niri/niri_config/scripts/ghostty
git diff --check

for host in Drgnfly FireFly Lily; do
  nix eval --offline --no-write-lock-file --json \
    ".#nixosConfigurations.${host}.config.home-manager.users.sinh.programs.ghostty.settings"
done
```

Home Manager normalizes scalar settings to lists: expect `background = ["#1c1c2b"]` and `background-opacity = [1.0]`. Compare all other settings with the baseline, not just the canvas. Missing offline inputs are blocked checks, not permission to update the lock file. Source evaluation is not activation or visual acceptance.

## Operator activation and acceptance

Agents must not run privileged commands. Sinh may temporarily activate the reviewed checkout on the intended host:

```bash
sudo sys test .
```

The directory argument is significant: run in the reviewed checkout, not an unrelated branch. Open fresh bare Ghostty and Herdr windows after activation; existing processes may retain old settings. Then verify:

1. On the same monitor and capture pipeline, sample three unobstructed blank canvas points in raw PNGs. Each must be RGB(28,28,43), including after manually choosing a contrasting wallpaper. Restore the original wallpaper afterward.
2. In the same blank window, use the actual Ctrl+Enter interaction for two normal/fullscreen/normal round trips. Every sample must remain identical. A compositor-only test does not prove the keyboard binding works.
3. Compare a bare shell with a Herdr shell pane; switch tabs and pane focus. Check selected safe text, readable prompts/ANSI colors and a distinguishable active tab. Do not sample intentional chrome.
4. Confirm normal font/padding, Ctrl+Shift+X close in a disposable window, and the existing Herdr prefix navigation and prefix+z zoom. Separately check the Niri script's `-F` launch path without changing its font/padding behavior.
5. Inspect the exact source diff and the evaluated settings for all three enabled hosts. Record any failed or unavailable check separately; do not relax the pixel target silently.

If accepted, Sinh may activate persistently and repeat the fresh-window checks:

```bash
sudo sys rebuild .
```

A successful build or generated-config screenshot is not human UAT or proof of post-activation persistence. Keep the exact candidate, raw pixel evidence and operator results in the executing deployment's artifact directory. If rollback is necessary, make a reviewed inverse change to the appearance settings and let Sinh reactivate; never reset unrelated source or deployed state.
