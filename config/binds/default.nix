{
  osConfig,
  config,
  pkgs,
  lib,
  niriLib,
  ...
}: let
  cfg = osConfig.modules.desktop.niri;
in {
  imports = [
    ./screenshots.nix
    ./screenrecording.nix
  ];

  programs.niri.settings.binds = with lib;
  with config.lib.niri.actions; let
    sh = spawn "sh" "-c";

    mkMenu = niriLib.niri.mkMenu;

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

      # Window focus menu
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
        {
          key = "1";
          desc = "Column width 30%";
          cmd = "niri msg action set-column-width 30%";
        }
        {
          key = "2";
          desc = "Column width 48%";
          cmd = "niri msg action set-column-width 48%";
        }
        {
          key = "3";
          desc = "Column width 65%";
          cmd = "niri msg action set-column-width 65%";
        }
        {
          key = "4";
          desc = "Column width 95%";
          cmd = "niri msg action set-column-width 95%";
        }
      ])}";

      # Window move menu
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

      # Window resize menu
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

      # Workspace switching
      "Mod+Ctrl+H".action = focus-workspace-down;
      "Mod+Ctrl+L".action = focus-workspace-up;
      "Mod+Down".action = focus-workspace-down;
      "Mod+Up".action = focus-workspace-up;

      # Monitor focus
      "Mod+Shift+H".action = focus-monitor-left;
      "Mod+Shift+L".action = focus-monitor-right;
      "Mod+Shift+Left".action = focus-monitor-left;
      "Mod+Shift+Right".action = focus-monitor-right;

      # Move workspace between monitors
      "Mod+Shift+Alt+H".action = move-workspace-to-monitor-left;
      "Mod+Shift+Alt+L".action = move-workspace-to-monitor-right;
      "Mod+Shift+Alt+K".action = move-workspace-to-monitor-up;
      "Mod+Shift+Alt+J".action = move-workspace-to-monitor-down;
      "Mod+Shift+Alt+Left".action = move-workspace-to-monitor-left;
      "Mod+Shift+Alt+Right".action = move-workspace-to-monitor-right;

      # Interactive column resizing
      # "Mod+BracketLeft".action.resize-column-width-left = [];
      # "Mod+BracketRight".action.resize-column-width-right = [];

      # Dynamic cast
      "Mod+Insert".action = set-dynamic-cast-window;
      "Mod+Shift+Insert".action = set-dynamic-cast-monitor;
      "Mod+Delete".action = clear-dynamic-cast-target;

      # Column tabbed display
      "Mod+Ctrl+Space".action = toggle-column-tabbed-display;

      # Tab navigation
      "Mod+Tab".action = focus-window-down-or-column-right;
      "Mod+Shift+Tab".action = focus-window-up-or-column-left;

      # Media controls
      "XF86AudioPlay".action = sh "playerctl play-pause";
      "XF86AudioPrev".action = sh "playerctl previous";
      "XF86AudioNext".action = sh "playerctl next";

      # Volume controls
      # "Mod+PageUp".action = sh "${pkgs.pipewire}/bin/wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 5%+";
      # "Mod+PageDown".action = sh "${pkgs.pipewire}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      # "Mod+M".action = sh "${pkgs.pipewire}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

      # Application launcher menu
      "Mod+A".action = sh "${lib.getExe (mkMenu [
        {
          key = "s";
          desc = "Ferdium";
          cmd = "ferdium";
        }
        {
          key = "p";
          desc = "PhpStorm";
          cmd = "phpstorm";
        }
        {
          key = "d";
          desc = "DataGrip";
          cmd = "datagrip";
        }
        {
          key = "w";
          desc = "WebStorm";
          cmd = "webstorm";
        }
        {
          key = "l";
          desc = "Discord";
          cmd = "legcord";
        }
        {
          key = "f";
          desc = "Firefox";
          cmd = "firefox";
        }
        {
          key = "c";
          desc = "VSCode";
          cmd = "code";
        }
        {
          key = "e";
          desc = "File Manager";
          cmd = "${fileManager}";
        }
        {
          key = "t";
          desc = "Terminal";
          cmd = "${terminal}";
        }
      ])}";
    };
}
