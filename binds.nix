{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = osConfig.modules.desktop.niri;
in {
  programs.niri.settings.binds = with lib;
  with config.lib.niri.actions; let
    sh = spawn "sh" "-c";

    # mkMenu: Create interactive menu using wlr-which-key (same as Hyprland)
    mkMenu = menu: let
      configFile = builtins.toFile "config.yaml"
        (lib.generators.toYAML {} {
          anchor = "bottom-right";
          inherit menu;
        });
    in pkgs.writeShellScriptBin "niri-menu" ''
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';

    # Determine which applications to use
    terminal =
      if cfg.terminal != null
      then getExe cfg.terminal
      else if (config.modules.functionality.defaults.terminal or null) != null
      then getExe config.modules.functionality.defaults.terminal
      else null;

    browser =
      if cfg.browser != null
      then getExe cfg.browser
      else if (config.modules.functionality.defaults.browser or null) != null
      then getExe config.modules.functionality.defaults.browser
      else null;

    editor =
      if cfg.editor != null
      then getExe cfg.editor
      else if (config.modules.functionality.defaults.editor or null) != null
      then getExe config.modules.functionality.defaults.editor
      else null;

    fileManager =
      if cfg.fileManager != null
      then getExe cfg.fileManager
      else if (config.modules.functionality.defaults.fileManager or null) != null
      then getExe config.modules.functionality.defaults.fileManager
      else null;

    passwordManager =
      if cfg.passwordManager != null
      then "${getExe cfg.passwordManager} --quick-access"
      else if (config.modules.functionality.defaults.passwordManager or null) != null
      then "${getExe config.modules.functionality.defaults.passwordManager} --quick-access"
      else null;

    # Application binds (only if apps are defined)
    appBinds =
      lib.optionalAttrs (terminal != null) {
        "Mod+Return".action = spawn terminal;
      }
      // lib.optionalAttrs (browser != null) {
        "Mod+B".action = spawn browser;
      }
      // lib.optionalAttrs (fileManager != null) {
        "Mod+E".action = spawn fileManager;
      }
      // lib.optionalAttrs (passwordManager != null) {
        "Ctrl+Shift+Space".action = sh passwordManager;
      };

    workspaceBinds = builtins.listToAttrs (builtins.concatLists (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
          workspace = x + 1;
        in [
          {
            name = "Mod+${ws}";
            value.action.focus-workspace = workspace;
          }
          {
            name = "Mod+Shift+${ws}";
            value.action.move-column-to-workspace = workspace;
          }
        ]
      )
      10));
  in
    workspaceBinds
    // appBinds
    // {
      "Mod+O".action = show-hotkey-overlay;

      # window management
      "Mod+Q".action = close-window;
      "Mod+T".action = toggle-window-floating;

      # Window maximization
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action.fullscreen-window = [];
      "Mod+Ctrl+F".action.toggle-windowed-fullscreen = [];
      "Mod+Alt+F".action.maximize-window-to-edges = [];

      # Window focus movement (vim keys)
      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;
      "Mod+K".action = focus-window-up;
      "Mod+J".action = focus-window-down;

      # Window focus menu (interactive - matches Hyprland)
      "Mod+W".action = sh "${lib.getExe (mkMenu [
        {
          key = "h";
          desc = "Focus column left";
          cmd = "niri msg action focus-column-left";
        }
        {
          key = "l";
          desc = "Focus column right";
          cmd = "niri msg action focus-column-right";
        }
        {
          key = "k";
          desc = "Focus window up";
          cmd = "niri msg action focus-window-up";
        }
        {
          key = "j";
          desc = "Focus window down";
          cmd = "niri msg action focus-window-down";
        }
      ])}";

      # Window move menu (interactive - matches Hyprland)
      "Mod+Shift+W".action = sh "${lib.getExe (mkMenu [
        {
          key = "h";
          desc = "Move column left";
          cmd = "niri msg action move-column-left";
        }
        {
          key = "l";
          desc = "Move column right";
          cmd = "niri msg action move-column-right";
        }
        {
          key = "k";
          desc = "Move window up";
          cmd = "niri msg action move-window-up";
        }
        {
          key = "j";
          desc = "Move window down";
          cmd = "niri msg action move-window-down";
        }
      ])}";

      # Window resize menu (interactive - matches Hyprland)
      "Mod+Z".action = sh "${lib.getExe (mkMenu [
        {
          key = "h";
          desc = "Resize column left";
          cmd = "niri msg action set-column-width -40";
        }
        {
          key = "l";
          desc = "Resize column right";
          cmd = "niri msg action set-column-width +40";
        }
        {
          key = "k";
          desc = "Resize window up";
          cmd = "niri msg action set-window-height -40";
        }
        {
          key = "j";
          desc = "Resize window down";
          cmd = "niri msg action set-window-height +40";
        }
      ])}";

      # Workspace switching (consistent with Hyprland - using Ctrl+H/L)
      "Mod+Ctrl+H".action = focus-workspace-down;
      "Mod+Ctrl+L".action = focus-workspace-up;
      "Mod+Down".action = focus-workspace-down;
      "Mod+Up".action = focus-workspace-up;

      # Monitor focus (Ctrl modifier - same as Hyprland)
      "Mod+Shift+H".action = focus-monitor-left;
      "Mod+Shift+L".action = focus-monitor-right;
      "Mod+Shift+Left".action = focus-monitor-left;
      "Mod+Shift+Right".action = focus-monitor-right;

      # move workspace between monitors (SHIFT+ALT - matches Hyprland)
      "Mod+Shift+Alt+H".action = move-workspace-to-monitor-left;
      "Mod+Shift+Alt+L".action = move-workspace-to-monitor-right;
      "Mod+Shift+Alt+K".action = move-workspace-to-monitor-up;
      "Mod+Shift+Alt+J".action = move-workspace-to-monitor-down;
      "Mod+Shift+Alt+Left".action = move-workspace-to-monitor-left;
      "Mod+Shift+Alt+Right".action = move-workspace-to-monitor-right;

      # Interactive column resizing
      # "Mod+BracketLeft".action.resize-column-width-left = [];
      # "Mod+BracketRight".action.resize-column-width-right = [];

      # dynamic cast
      "Mod+Insert".action = set-dynamic-cast-window;
      "Mod+Shift+Insert".action = set-dynamic-cast-monitor;
      "Mod+Delete".action = clear-dynamic-cast-target;

      # column tabbed display
      "Mod+Ctrl+Space".action = toggle-column-tabbed-display;

      # tab navigation
      "Mod+Tab".action = focus-window-down-or-column-right;
      "Mod+Shift+Tab".action = focus-window-up-or-column-left;

      # screenshots
      # "Mod+Shift+S".action.screenshot = [];
      "Mod+Shift+S" = let
        flameshot = pkgs.flameshot.override {enableWlrSupport = true;};
      in {
        action = spawn "${getExe flameshot} gui";
        hotkey-overlay.title = "Flameshot";
      };
      "Mod+Ctrl+S".action.screenshot-window = [];
      "Mod+Ctrl+Shift+S".action.screenshot-screen = [];

      # media controls
      "XF86AudioPlay".action = sh "playerctl play-pause";
      "XF86AudioPrev".action = sh "playerctl previous";
      "XF86AudioNext".action = sh "playerctl next";

      # Volume Controls
      # "Mod+PageUp".action = sh "${pkgs.pipewire}/bin/wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%+";
      # "Mod+PageDown".action = sh "${pkgs.pipewire}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      # "Mod+M".action = sh "${pkgs.pipewire}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

      # apps
      "Mod+S".action = spawn "ferdium";

      # Application launcher menu (matches Hyprland)
      "Mod+A".action = sh "${lib.getExe (mkMenu [
        {
          key = "p";
          desc = "Open PhpStorm";
          cmd = "phpstorm";
        }
        {
          key = "d";
          desc = "Open DataGrip";
          cmd = "datagrip";
        }
        {
          key = "w";
          desc = "Open WebStorm";
          cmd = "webstorm";
        }
        {
          key = "s";
          desc = "Open Slack";
          cmd = "slack";
        }
        {
          key = "l";
          desc = "Open Discord";
          cmd = "legcord";
        }
        {
          key = "f";
          desc = "Open Firefox";
          cmd = "firefox";
        }
        {
          key = "c";
          desc = "Open VSCode";
          cmd = "code";
        }
        {
          key = "e";
          desc = "Open File Manager";
          cmd = "${fileManager}";
        }
        {
          key = "t";
          desc = "Open Terminal";
          cmd = "${terminal}";
        }
      ])}";
    };
}
