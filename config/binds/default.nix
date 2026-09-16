{
  osConfig,
  config,
  lib,
  pkgs,
  niriLib,
  ...
}: let
  cfg = osConfig.modules.desktop.niri;

  app = name:
    lib.mapNullable lib.getExe (
      if cfg.${name} != null
      then cfg.${name}
      else config.modules.functionality.defaults.${name} or null
    );

  terminal = app "terminal";
  browser = app "browser";
  editor = app "editor";
  fileManager = app "fileManager";
  passwordManager = lib.mapNullable (exe: "${exe} --quick-access") (app "passwordManager");
in {
  imports = [
    ./screenshots.nix
    ./screenrecording.nix
  ];

  programs.niri.settings.binds = with lib;
  with config.lib.niri.actions; let
    sh = spawn "sh" "-c";

    mkMenu = niriLib.mkMenu;
    playerctl = getExe pkgs.playerctl;

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
            toString (x + 1 - (c * 10));
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
      "Mod+W".action = sh "${mkMenu [
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
      ]}";

      # Window move menu
      "Mod+Shift+W".action = sh "${mkMenu [
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
      ]}";

      # Window resize menu
      "Mod+Z".action = sh "${mkMenu [
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
      ]}";

      # Workspace switching
      "Mod+Ctrl+H".action = focus-workspace-down;
      "Mod+Ctrl+L".action = focus-workspace-up;
      "Mod+Down".action = focus-workspace-down;
      "Mod+Up".action = focus-workspace-up;
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;

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
      "XF86AudioPlay".action = spawn playerctl "play-pause";
      "XF86AudioPrev".action = spawn playerctl "previous";
      "XF86AudioNext".action = spawn playerctl "next";

      # Not Mod+M: DMS's included binds.kdl loads after hm.kdl and takes it.
      "Mod+X".action = spawn "niri-scratchpad" "create" "1";
      "Mod+Shift+X".action = spawn "niri-scratchpad" "create" "1" "--as-float";
      "Mod+Ctrl+X".action = spawn "niri-scratchpad" "delete" "1";

      # Application launcher menu
      "Mod+A".action = sh "${mkMenu ([
          {
            key = "s";
            desc = "Ferdium";
            cmd = "ferdium";
          }
          {
            key = "l";
            desc = "Discord";
            cmd = "legcord";
          }
        ]
        ++ lib.filter (entry: entry.cmd != null) [
          {
            key = "e";
            desc = "File Manager";
            cmd = fileManager;
          }
          {
            key = "t";
            desc = "Terminal";
            cmd = terminal;
          }
          {
            key = "b";
            desc = "Browser";
            cmd = browser;
          }
          {
            key = "p";
            desc = "Password Manager";
            cmd = passwordManager;
          }
          {
            key = "n";
            desc = "Editor";
            cmd = editor;
          }
        ])}";
    };
}
