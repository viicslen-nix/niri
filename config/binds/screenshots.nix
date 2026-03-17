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

    mkMenu = menu: let
      configFile =
        pkgs.writeText "config.yaml"
        (lib.generators.toYAML {} {
          anchor = "bottom-right";
          inherit menu;
        });
    in
      lib.getExe (pkgs.writeShellScriptBin "niri-menu" ''
        exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
      '');

    flameshot = pkgs.flameshot.override {enableWlrSupport = true;};
    wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
    screenshotFile = "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png";

    # One entry per capture scope; each action (save/clip/edit) maps over this list
    screenshotScopes = [
      {
        key = "a";
        desc = "All monitors";
        grimArgs = "";
        saveCmd = null;
        flameshotArgs = "full";
      }
      {
        key = "m";
        desc = "Single monitor";
        grimArgs = "-o \"$(niri msg -j outputs | ${lib.getExe pkgs.jq} -r 'first | .name')\"";
        saveCmd = "niri msg action screenshot-screen";
        flameshotArgs = "screen";
      }
      {
        key = "w";
        desc = "Single window";
        grimArgs = "-g \"$(niri msg -j focused-window | ${lib.getExe pkgs.jq} -r '\"\\(.geometry.x),\\(.geometry.y) \\(.geometry.width)x\\(.geometry.height)\"')\"";
        saveCmd = "niri msg action screenshot-window";
        flameshotArgs = "gui";
      }
      {
        key = "r";
        desc = "Region";
        grimArgs = "-g \"$(${lib.getExe pkgs.slurp})\"";
        saveCmd = null;
        flameshotArgs = "gui";
      }
    ];
  in {
    # Action first, then capture scope
    "Mod+Shift+S".action = sh "${mkMenu [
      {
        key = "s";
        desc = "Save & copy to clipboard";
        submenu =
          map (scope: {
            inherit (scope) key desc;
            cmd =
              if scope.saveCmd != null
              then scope.saveCmd
              else "FILE=${screenshotFile}; grim ${scope.grimArgs} \"$FILE\" && ${wlCopy} < \"$FILE\"";
          })
          screenshotScopes;
      }
      {
        key = "c";
        desc = "Clipboard only";
        submenu =
          map (scope: {
            inherit (scope) key desc;
            cmd = "grim ${scope.grimArgs} - | ${wlCopy}";
          })
          screenshotScopes;
      }
      {
        key = "f";
        desc = "Open with Flameshot";
        submenu =
          map (scope: {
            inherit (scope) key desc;
            cmd = "${lib.getExe flameshot} ${scope.flameshotArgs}";
          })
          screenshotScopes;
      }
    ]}";

    # Native niri screenshot shortcuts
    "Mod+Ctrl+S".action.screenshot-window = [];
    "Mod+Ctrl+Shift+S".action.screenshot-screen = [];
  };
}
