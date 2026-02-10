# Niri Desktop Environment Flake

A modern NixOS flake providing a complete Niri tiling window manager configuration with Material Design shell and advanced workspace management.

## Overview

This flake provides a complete Niri desktop setup including:

- Niri scrollable tiling window manager
- DankMaterialShell for modern Material Design interface
- Dynamic workspace and monitor management
- Advanced window rules and layout presets
- Integrated application launching and shortcuts
- Stylix theme integration support
- XWayland satellite for legacy X11 app support

## Features

- **Window Manager**: Niri with scrollable tiling layout
- **Shell Interface**: DankMaterialShell with Material Design
- **Theme Integration**: Automatic Stylix color scheme support
- **Workspace Management**: 10 workspaces with dynamic switching
- **Window Rules**: Rounded corners, floating windows, and custom layouts
- **Application Integration**: Configurable default applications
- **Media Controls**: Playerctl integration for audio/video
- **Screenshot Support**: Built-in screenshot functionality
- **Focus Management**: Mouse focus following and auto-centering
- **Authentication**: GNOME Polkit and Keyring integration

## Structure

```text
.
├── flake.nix              # Main flake definition with inputs
├── default.nix           # NixOS module implementation
├── binds.nix             # Keybindings and shortcuts configuration
├── rules.nix             # Window and layer rules
├── settings.nix          # Niri compositor settings
├── shell.nix             # DankMaterialShell configuration
└── README.md             # This file
```

## Dependencies

The flake integrates several upstream projects:

- **niri-flake**: Main Niri compositor and NixOS integration
- **DankMaterialShell**: Material Design shell interface
- **dgop**: Additional utilities
- **dms-cli**: DankLinux command-line tools

## Usage

### As a NixOS Module

Add this flake as an input to your system flake:

```nix
{
  inputs = {
    # ... other inputs
    niri-config.url = "path:./flakes/niri";
    niri-config.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, niri-config, ... }: {
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      modules = [
        niri-config.nixosModules.default
        {
          modules.desktop.niri.enable = true;
        }
      ];
    };
  };
}
```

### Configuration Options

The module provides several configuration options for default applications:

```nix
modules.desktop.niri = {
  enable = true;                           # Enable the Niri desktop

  # Default applications (optional - uses system defaults if not set)
  terminal = pkgs.alacritty;              # Terminal emulator
  browser = pkgs.firefox;                 # Web browser
  editor = pkgs.neovim;                   # Text editor
  fileManager = pkgs.nautilus;            # File manager
  passwordManager = pkgs.bitwarden;       # Password manager
};
```

If any application options are set to `null` (default), the module will automatically use the corresponding application from `modules.functionality.defaults` if available.

## Keybindings

This configuration uses a **unified keymap system** designed for muscle memory consistency across window managers (Hyprland/Niri) and editors (Neovim/Nixvim). See the **Unified Keymap Philosophy** section below for details.

### Modifier Key
- **Primary Modifier**: `Mod` (SUPER/Windows key)

### Navigation Philosophy
All navigation follows vim conventions:
- **H** = Left
- **J** = Down
- **K** = Up
- **L** = Right

### Modifier Layers
Consistent modifier stacking across the system:
- **Base (Mod)**: Focus/navigate
- **+ SHIFT**: Move monitor focus
- **+ CTRL**: Workspace navigation
- **+ SHIFT + ALT**: Cross-monitor workspace operations

### Core Keybinds

**Window Management**
| Keybind | Action |
|---------|--------|
| `Mod + Q` | Close window |
| `Mod + T` | Toggle floating |
| `Mod + F` | Maximize column |
| `Mod + Shift + F` | Fullscreen window |
| `Mod + Ctrl + F` | Toggle windowed fullscreen |
| `Mod + Alt + F` | Maximize to edges |
| `Mod + Ctrl + Space` | Toggle column tabbed display |

**Focus Movement (Vim keys)**
| Keybind | Action |
|---------|--------|
| `Mod + H` | Focus column left |
| `Mod + L` | Focus column right |
| `Mod + J` | Focus window down |
| `Mod + K` | Focus window up |

**Interactive Menus (using wlr-which-key)**
| Keybind | Menu | Actions |
|---------|------|---------|
| `Mod + W` | Window Focus | `h/j/k/l` to move focus |
| `Mod + Shift + W` | Window Move | `h/j/k/l` to move window/column |
| `Mod + Z` | Window Resize | `h/j/k/l` to resize (±40px) |
| `Mod + A` | Application Launcher | See applications section |

**Workspace Navigation**
| Keybind | Action |
|---------|--------|
| `Mod + 1-0` | Focus workspace 1-10 |
| `Mod + Shift + 1-0` | Move column to workspace 1-10 |
| `Mod + Ctrl + H` | Focus workspace down |
| `Mod + Ctrl + L` | Focus workspace up |
| `Mod + Up/Down` | Focus workspace up/down (arrows) |

**Monitor Management**
| Keybind | Action |
|---------|--------|
| `Mod + Shift + H/L` | Focus monitor left/right |
| `Mod + Shift + Left/Right` | Focus monitor left/right (arrows) |
| `Mod + Shift + Alt + H/J/K/L` | Move workspace to monitor |
| `Mod + Shift + Alt + Left/Right` | Move workspace to monitor (arrows) |

**Tab Navigation**
| Keybind | Action |
|---------|--------|
| `Mod + Tab` | Focus window down or column right |
| `Mod + Shift + Tab` | Focus window up or column left |

**Applications**
| Keybind | Action |
|---------|--------|
| `Mod + Return` | Terminal (if configured) |
| `Mod + B` | Browser (if configured) |
| `Mod + E` | File Manager (if configured) |
| `Mod + S` | Ferdium |
| `Ctrl + Shift + Space` | Password Manager |

**Application Menu (`Mod + A`)**
| Key | Application |
|-----|-------------|
| `p` | PhpStorm |
| `d` | DataGrip |
| `w` | WebStorm |
| `s` | Slack |
| `l` | Discord |
| `f` | Firefox |
| `c` | VSCode |
| `e` | File Manager |
| `t` | Terminal |

**Screenshots**
| Keybind | Action |
|---------|--------|
| `Mod + Shift + S` | Flameshot GUI |
| `Mod + Ctrl + S` | Screenshot active window |
| `Mod + Ctrl + Shift + S` | Screenshot entire screen |

**Dynamic Cast (Screen Sharing)**
| Keybind | Action |
|---------|--------|
| `Mod + Insert` | Set dynamic cast window |
| `Mod + Shift + Insert` | Set dynamic cast monitor |
| `Mod + Delete` | Clear dynamic cast target |

**Media Controls**
| Keybind | Action |
|---------|--------|
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioPrev/Next` | Previous/Next track |

**System**
| Keybind | Action |
|---------|--------|
| `Mod + O` | Show hotkey overlay (native) |

### Unified Keymap Philosophy

This configuration implements **cross-system keymap standardization** to reduce cognitive load and improve muscle memory:

**Design Principles:**
1. **Vim-style navigation everywhere**: H/J/K/L for all directional movement
2. **Consistent modifier layers**: Same patterns across Hyprland and Niri
3. **Interactive menus**: wlr-which-key menus for grouped actions (matching Hyprland)
4. **Namespace-based launchers**: Application menu (`Mod+A`) mirrors editor leader patterns
5. **Mnemonic consistency**: Same keys for same concepts across systems

**Cross-System Consistency:**
- **Close/Quit**: `Mod+Q` (WM), `<leader>q` (Neovim)
- **Explorer/Files**: `Mod+E` (file manager), `<leader>e` (file tree)
- **Focus Movement**: `Mod+H/J/K/L` (WM columns/windows), `Ctrl+H/J/K/L` (Neovim splits)
- **Menu System**: Both WMs use wlr-which-key for interactive menus
- **Modifier Layering**: Base→SHIFT→CTRL→SHIFT+ALT hierarchy is identical

**Menu System Implementation:**
- Uses wlr-which-key (same as Hyprland) for visual interactive menus
- Bottom-right anchor position for consistency
- YAML-based configuration for easy modification
- Supports chording: press `Mod+W`, then `h/j/k/l` for actions

See the Hyprland, Nixvim, and Neovim READMEs for their implementations of this unified system.

## Window Rules

### Global Window Rules

- **Rounded Corners**: 8px radius on all corners
- **Border Clipping**: Windows clip to geometry
- **Border Drawing**: Borders drawn without background

### Application-Specific Rules

#### Ferdium

- Opens in floating mode with focus
- 50% column width proportion
- Positioned on the right side with 16px margin
- Blocked from screencasting

## Layout Configuration

### Column Presets

The layout includes several preset column widths:

- 30% (0.3 proportion)
- 48% (0.48 proportion)
- 65% (0.65 proportion)
- 95% (0.95 proportion) - default

### Layout Settings

- **Gaps**: 16px between windows
- **Border Width**: 4px
- **Center Single Column**: Always centers single columns
- **Default Width**: 95% proportion

## Shell Integration

### DankMaterialShell Features

- Material Design interface components
- Niri-specific spawn and keybind integration
- Automatic Stylix theme integration
- Custom theme generation from Stylix colors

### Theme Configuration

When Stylix is enabled, the shell automatically generates a custom theme using your Stylix color scheme, mapping colors to Material Design tokens:

- Primary colors from base0C and base0D
- Surface colors from base00-base02
- Text colors from base04-base07
- Accent colors from base0E

## Startup Applications

The configuration automatically starts:

1. **GNOME Polkit Agent**: For authentication dialogs
2. **GNOME Keyring**: For credential management
3. **Password Manager**: Silently starts configured password manager

## Advanced Features

### Focus Management

- **Mouse Focus Following**: Windows gain focus when mouse enters
- **Mouse Warping**: Mouse automatically centers on focused windows
- **Smart Scrolling**: Prevents accidental workspace switching

### Cursor Behavior

- **Hide When Typing**: Cursor disappears during text input
- **Auto Hide**: Cursor hides after 2 seconds of inactivity

### Screenshots

- Automatic screenshot naming with timestamp
- Saved to `~/Pictures/Screenshots/` directory
- Format: `YYYY-MM-DDTHHMMSS.png`

### XWayland Support

- XWayland Satellite for improved X11 application compatibility
- Seamless integration with legacy applications

## Customization

### Modifying Keybindings

Edit `binds.nix` to customize shortcuts and add new application bindings.

### Adjusting Window Rules

Edit `rules.nix` to modify window behavior, floating rules, and workspace assignments.

### Changing Layout Settings

Edit `settings.nix` to adjust:

- Gap sizes and border widths
- Column width presets
- Focus and cursor behavior
- Startup applications

### Shell Customization

Edit `shell.nix` to configure:

- DankMaterialShell settings
- Theme overrides
- Material Design tokens

## Troubleshooting

### Application Not Opening

Verify that the application package is installed and the correct executable path is used in the configuration.

### Focus Issues

Check that focus-follows-mouse and mouse warping settings are configured correctly in `settings.nix`.

### Theme Not Applied

Ensure Stylix is enabled in your system configuration and the theme JSON is being generated correctly.

### XWayland Problems

Verify that XWayland Satellite is available and the path is correct in the settings.

## Contributing

When modifying this flake:

1. Test changes with your specific application set
2. Ensure keybindings don't conflict with applications
3. Update this README when adding new features
4. Consider compatibility with different monitor setups
5. Test window rules with various application types

## License

This configuration follows the same license as your NixOS configuration.
