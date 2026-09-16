# Niri Desktop Flake

A NixOS module that sets up the [niri](https://github.com/YaLTeR/niri)
scrollable-tiling Wayland compositor, with home-manager settings, window rules
and keybinds. The shell (DMS, Noctalia, …) is not part of this flake: niri only
starts `desktop-shell.target`, and the root repo's shell module binds the
selected shell to it.

Why things are the way they are: [CONTEXT.md](./CONTEXT.md).

## What it sets up

**NixOS**

- `programs.niri` with `niri-unstable` from niri-flake's overlay.
- [niri-scratchpad](https://github.com/argosnothing/niri-scratchpad) and the
  Adwaita icon, font and Qt theme packages.
- niri-flake's own polkit agent is disabled.
- `xdg-desktop-portal-wlr` handles the Screenshot portal; everything else uses
  gnome, then gtk.

**home-manager** (only when home-manager is loaded, via `sharedModules`)

- `settings.nix`: `prefer-no-csd`, xwayland-satellite, screenshot path
  `~/Pictures/Screenshots/`, cursor hiding (while typing and after 2s),
  mouse warp to focus, focus-follows-mouse, `compose:rwin`, 16px gaps, 4px
  borders, column presets 30/48/65/95% (default 95%), window height presets
  40/50/60%, and the `stash` workspace niri-scratchpad needs. At startup it
  runs gnome-keyring (secrets) and starts `desktop-shell.target`.
- `rules.nix`: 8px rounded corners with clipping; Ferdium floats on the right
  and is blocked from screencasts; the Flameshot overlay and Satty open
  floating and fullscreen; the DMS blurred wallpaper layer is placed in the
  backdrop.
- `binds/`: the keybinds below. Menus use wlr-which-key, anchored bottom-right.
- `niriLib`: the `wayland` helpers (`mkMenu`, `mkRecordCmd`) from the lib
  subflake.

## Usage

The root flake takes this as `path:./flakes/niri` and imports
`nixosModules.default`.

```nix
modules.desktop.niri = {
  enable = true;
  # Optional. When null, falls back to home-manager's
  # modules.functionality.defaults.<name>; binds for unset apps are skipped.
  terminal = pkgs.ghostty;
  browser = pkgs.firefox;
  editor = pkgs.zed-editor;
  fileManager = pkgs.nautilus;
  passwordManager = pkgs._1password-gui; # launched with --quick-access
};
```

## Keybinds

`Mod` is Super. Directions follow vim: H/J/K/L. On DMS hosts, DMS's
`dms/binds.kdl` is included after these and overrides any key both define, so
new binds must avoid the keys it uses (`Mod+M`, `Mod+N`, `Mod+V`, `Mod+Space`,
`Mod+Comma`, `Mod+Y`, …).

**Windows**

| Keys | Action |
|---|---|
| `Mod+Q` | Close window |
| `Mod+T` | Toggle floating |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen |
| `Mod+Ctrl+F` | Toggle windowed fullscreen |
| `Mod+Alt+F` | Maximize window to edges |
| `Mod+Ctrl+Space` | Toggle tabbed column |
| `Mod+H` / `Mod+L`, `Mod+Left` / `Mod+Right` | Focus column left / right |
| `Mod+K` / `Mod+J` | Focus window up / down |
| `Mod+Tab` / `Mod+Shift+Tab` | Focus next / previous (window, then column) |
| `Mod+W` | Menu: focus `h/j/k/l`, column width `1-4` (30/48/65/95%) |
| `Mod+Shift+W` | Menu: move column/window `h/j/k/l` |
| `Mod+Z` | Menu: resize `h/l` column width, `k/j` window height (±40) |
| `Mod+O` | Hotkey overlay |

**Workspaces and monitors**

| Keys | Action |
|---|---|
| `Mod+1`…`Mod+0` | Focus workspace 1–10 |
| `Mod+Shift+1`…`Mod+Shift+0` | Move column to workspace 1–10 |
| `Mod+Ctrl+H` / `Mod+Ctrl+L`, `Mod+Down` / `Mod+Up` | Focus workspace down / up |
| `Mod+Shift+H` / `Mod+Shift+L` (or arrows) | Focus monitor left / right |
| `Mod+Shift+Alt+H/J/K/L` (or Left/Right) | Move workspace to monitor |

**Scratchpad** (niri-scratchpad register 1)

| Keys | Action |
|---|---|
| `Mod+X` | Assign the focused window, or toggle it |
| `Mod+Shift+X` | Same, floating the window on first assign |
| `Mod+Ctrl+X` | Release the register and restore its window |

**Applications**

| Keys | Action |
|---|---|
| `Mod+Return` | Terminal |
| `Mod+B` | Browser |
| `Mod+E` | File manager |
| `Ctrl+Shift+Space` | Password manager quick access |
| `Mod+A` | Menu: `s` Ferdium, `l` Legcord, and when configured `e` file manager, `t` terminal, `b` browser, `p` password manager, `n` editor |

**Screenshots**

| Keys | Action |
|---|---|
| `Mod+Shift+S` | Menu: `s` save and copy, `c` clipboard only (each then `a` all monitors, `m` focused monitor, `w` focused window, `r` region), `f` Flameshot, `e` capture the focused monitor and crop in Satty |
| `Mod+Ctrl+S` | niri: screenshot window |
| `Mod+Ctrl+Shift+S` | niri: screenshot screen |

**Screen recording** (wl-screenrec, saved to `~/Videos/Recordings/`)

| Keys | Action |
|---|---|
| `Mod+Shift+R` | Menu: `a` focused monitor, `m` pick a monitor (wofi), `r` region (slurp), `q` stop |

**Other**

| Keys | Action |
|---|---|
| `Mod+Insert` / `Mod+Shift+Insert` | Dynamic cast: window / monitor |
| `Mod+Delete` | Clear dynamic cast target |
| `XF86AudioPlay` / `XF86AudioPrev` / `XF86AudioNext` | playerctl play-pause / previous / next |

## Structure

```text
.
├── flake.nix                 # inputs, nixosModules.default, checks
├── config/
│   ├── default.nix           # NixOS module: options, niri, portals, HM wiring
│   ├── settings.nix          # compositor settings
│   ├── rules.nix             # window and layer rules
│   └── binds/
│       ├── default.nix       # core binds, menus, launcher, scratchpad
│       ├── screenshots.nix
│       └── screenrecording.nix
├── CONTEXT.md
└── Justfile
```

## Check

```bash
just check    # nix flake check --print-build-logs
```

`checks.x86_64-linux.default` evaluates a minimal NixOS system with the module
and home-manager enabled, and writes its toplevel `drvPath` to a file. It does
not build the system.
