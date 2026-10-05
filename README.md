<div align="center">

# niri

**The niri desktop as one NixOS module: compositor, portals, settings, rules and keybinds.**

[![niri](https://img.shields.io/badge/WM-niri--unstable-E0A458?style=flat-square)](https://github.com/YaLTeR/niri)
[![niri-flake](https://img.shields.io/badge/built_on-niri--flake-7EBAE4?style=flat-square&logo=nixos&logoColor=white)](https://github.com/sodiboo/niri-flake)
[![Home Manager](https://img.shields.io/badge/Home_Manager-sharedModules-41439A?style=flat-square)](https://github.com/nix-community/home-manager)

</div>

A NixOS module for the [niri](https://github.com/YaLTeR/niri) scrollable-tiling
Wayland compositor, with home-manager settings, window rules and keybinds.

> [!NOTE]
> The desktop shell (DMS, Noctalia, …) is not part of this flake. niri only
> starts `desktop-shell.target`; the root repo's shell module binds the
> selected shell to it.

Why things are the way they are: [CONTEXT.md](./CONTEXT.md).

## Outputs

| Output | What it is |
| --- | --- |
| `nixosModules.default` | The module; declares `modules.desktop.niri` |
| `nixosModules.niri` | Alias of `default` |
| `formatter.<system>` | treefmt wrapper: deadnix, statix, alejandra |
| `checks.<system>.treefmt` | Fails if `nix fmt` would change anything |
| `checks.<system>.statix` | `statix check`, which catches what `statix fix` skips (repeated keys) |
| `checks.x86_64-linux.default` | Evaluates a minimal NixOS + home-manager system with the module enabled |

`<system>` is `x86_64-linux` or `aarch64-linux`.

## Usage

```nix
# flake.nix
inputs.niri = {
  url = "github:viicslen-nix/niri";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
# a NixOS module
{inputs, pkgs, ...}: {
  imports = [inputs.niri.nixosModules.default];

  modules.desktop.niri = {
    enable = true;
    # All optional. When null, falls back to home-manager's
    # modules.functionality.defaults.<name>; binds for unset apps are skipped.
    terminal = pkgs.ghostty;
    browser = pkgs.firefox;
    editor = pkgs.zed-editor;
    fileManager = pkgs.nautilus;
    passwordManager = pkgs._1password-gui; # launched with --quick-access
  };
}
```

In this repo the root flake takes it as `path:./flakes/niri`, and the `desktop`
preset imports `nixosModules.default`.

### Options

| Option | Type | Default |
| --- | --- | --- |
| `modules.desktop.niri.enable` | bool | `false` |
| `modules.desktop.niri.terminal` | package or null | `null` |
| `modules.desktop.niri.browser` | package or null | `null` |
| `modules.desktop.niri.editor` | package or null | `null` |
| `modules.desktop.niri.fileManager` | package or null | `null` |
| `modules.desktop.niri.passwordManager` | package or null | `null` |

## What it sets up

**NixOS**

| | |
| --- | --- |
| Compositor | `programs.niri` with `niri-unstable` from niri-flake's overlay |
| Packages | [niri-scratchpad](https://github.com/argosnothing/niri-scratchpad), Adwaita icons, fonts and Qt themes |
| Polkit | niri-flake's own agent is disabled |
| Portals | `xdg-desktop-portal-wlr` handles Screenshot; everything else uses gnome, then gtk |

**home-manager** — only when home-manager is loaded, via `home-manager.sharedModules`.

| File | Contents |
| --- | --- |
| `settings.nix` | `prefer-no-csd`, no hotkey overlay at startup, xwayland-satellite, screenshots to `~/Pictures/Screenshots/`, cursor hidden while typing and after 2s, mouse warp to focus, focus-follows-mouse, `compose:rwin`, 16px gaps, 4px borders, single column centred, column presets 30/48/65/95% (default 95%), window height presets 40/50/60%, the `stash` workspace niri-scratchpad needs. Starts gnome-keyring (secrets) and `desktop-shell.target`. |
| `rules.nix` | 8px rounded corners with clipping; Ferdium floats on the right at 50% and is blocked from screencasts; the Flameshot overlay and Satty open floating and fullscreen; the DMS blurred wallpaper layer goes in the backdrop |
| `binds/` | The keybinds below. Menus are wlr-which-key popups anchored bottom-right. |

The binds get `niriLib`, the `wayland` helpers (`mkMenu`, `mkRecordCmd`) from
the [lib subflake](https://github.com/viicslen-nix/lib).

## Keybinds

`Mod` is Super. Directions follow vim: H/J/K/L.

> [!IMPORTANT]
> On DMS hosts, DMS's `dms/binds.kdl` is included after these and overrides any
> key both define (it takes `Mod+M`, for one). Check
> `~/.config/niri/dms/binds.kdl` before picking a new key.

<details>
<summary><b>Full keybind reference</b></summary>

**Windows**

| Keys | Action |
| --- | --- |
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
| --- | --- |
| `Mod+1`…`Mod+0` | Focus workspace 1–10 |
| `Mod+Shift+1`…`Mod+Shift+0` | Move column to workspace 1–10 |
| `Mod+Ctrl+H` / `Mod+Ctrl+L`, `Mod+Down` / `Mod+Up` | Focus workspace down / up |
| `Mod+Shift+H` / `Mod+Shift+L` (or arrows) | Focus monitor left / right |
| `Mod+Shift+Alt+H/J/K/L` (or Left/Right) | Move workspace to monitor |

**Scratchpad** (niri-scratchpad register 1)

| Keys | Action |
| --- | --- |
| `Mod+X` | Assign the focused window, or toggle it |
| `Mod+Shift+X` | Same, floating the window on first assign |
| `Mod+Ctrl+X` | Release the register and restore its window |

**Applications**

| Keys | Action |
| --- | --- |
| `Mod+Return` | Terminal |
| `Mod+B` | Browser |
| `Mod+E` | File manager |
| `Ctrl+Shift+Space` | Password manager quick access |
| `Mod+A` | Menu: `s` Ferdium, `l` Legcord, and when configured `e` file manager, `t` terminal, `b` browser, `p` password manager, `n` editor |

**Screenshots**

| Keys | Action |
| --- | --- |
| `Mod+Shift+S` | Menu: `s` save and copy, `c` clipboard only (each then `a` all monitors, `m` focused monitor, `w` focused window, `r` region), `f` Flameshot, `e` capture the focused monitor and crop in Satty |
| `Mod+Ctrl+S` | niri: screenshot window |
| `Mod+Ctrl+Shift+S` | niri: screenshot screen |

**Screen recording** (wl-screenrec, saved to `~/Videos/Recordings/`)

| Keys | Action |
| --- | --- |
| `Mod+Shift+R` | Menu: `a` focused monitor, `m` pick a monitor (wofi), `r` region (slurp), `q` stop |

**Other**

| Keys | Action |
| --- | --- |
| `Mod+Insert` / `Mod+Shift+Insert` | Dynamic cast: window / monitor |
| `Mod+Delete` | Clear dynamic cast target |
| `XF86AudioPlay` / `XF86AudioPrev` / `XF86AudioNext` | playerctl play-pause / previous / next |

</details>

## Development

```bash
nix fmt                # deadnix, statix, alejandra via treefmt
nix flake check        # formatting, statix and the module eval
just check             # nix flake check --print-build-logs
```

The module check writes the evaluated toplevel's `drvPath` to a file; it never
builds the system.

<details>
<summary><b>Layout</b></summary>

```text
.
├── flake.nix                 # inputs, nixosModules, formatter, checks
├── treefmt.nix               # nix fmt: deadnix → statix → alejandra
├── config/
│   ├── default.nix           # NixOS module: options, niri, portals, HM wiring
│   ├── settings.nix          # compositor settings
│   ├── rules.nix             # window and layer rules
│   └── binds/
│       ├── default.nix       # core binds, menus, launcher, scratchpad
│       ├── screenshots.nix
│       └── screenrecording.nix
├── CONTEXT.md                # why things are the way they are
└── Justfile
```

</details>
