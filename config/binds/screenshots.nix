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
    grim = lib.getExe pkgs.grim;
    niriAction = "${lib.getExe pkgs.niri-unstable} msg action";
    envCmd = "${pkgs.coreutils}/bin/env";
    sleep = "${pkgs.coreutils}/bin/sleep";
    wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
    screenshotFile = "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png";

    mkShotScript = name: body:
      lib.getExe (pkgs.writeShellScriptBin name ''
        set -euo pipefail
        ${body}
      '');

    # One entry per capture scope; each action (save/clip/edit) maps over this list
    screenshotScopes = [
      {
        key = "a";
        desc = "All monitors";
        preCmd = "${sleep} 0.8";
        grimArgs = "";
        saveCmd = null;
        clipCmd = null;
      }
      {
        key = "m";
        desc = "Single monitor";
        preCmd = "${sleep} 0.8";
        grimArgs = "";
        saveCmd = ''${niriAction} screenshot-screen --path "$FILE"'';
        clipCmd = ''${niriAction} screenshot-screen --write-to-disk false'';
      }
      {
        key = "w";
        desc = "Single window";
        preCmd = "${sleep} 0.8";
        grimArgs = "";
        saveCmd = ''${niriAction} screenshot-window --path "$FILE"'';
        clipCmd = ''${niriAction} screenshot-window --write-to-disk false'';
      }
      {
        key = "r";
        desc = "Region";
        preCmd = "";
        grimArgs = "-g \"$(${lib.getExe pkgs.slurp})\"";
        saveCmd = null;
        clipCmd = null;
      }
    ];

    saveScopeMenu = mkMenu (
      map (scope: {
        inherit (scope) key desc;
        cmd = mkShotScript "niri-shot-save-${scope.key}" ''
          ${scope.preCmd}
          FILE=${screenshotFile}
          mkdir -p "$(dirname "$FILE")"
          ${
            if scope.saveCmd != null
            then scope.saveCmd
            else ''${grim} ${scope.grimArgs} "$FILE"''
          }
          ${wlCopy} < "$FILE"
        '';
      })
      screenshotScopes
    );

    clipboardScopeMenu = mkMenu (
      map (scope: {
        inherit (scope) key desc;
        cmd = mkShotScript "niri-shot-clip-${scope.key}" ''
          ${scope.preCmd}
          ${
            if scope.clipCmd != null
            then scope.clipCmd
            else ''${grim} ${scope.grimArgs} - | ${wlCopy}''
          }
        '';
      })
      screenshotScopes
    );

    flameshotGui = mkShotScript "niri-shot-flameshot-gui" ''
      ${sleep} 0.2
      exec ${envCmd} \
        DISPLAY= \
        XDG_CURRENT_DESKTOP=sway \
        XDG_SESSION_DESKTOP=sway \
        QT_QPA_PLATFORM=wayland \
        ${lib.getExe flameshot} gui
    '';

    # Native wlroots flow: grab the whole focused monitor, then crop/annotate
    # live in satty (region stays adjustable while editing, unlike slurp first).
    sattyEdit = mkShotScript "niri-shot-satty" ''
      FILE=${screenshotFile}
      mkdir -p "$(dirname "$FILE")"
      OUTPUT=$(${lib.getExe pkgs.niri-unstable} msg -j focused-output \
        | ${lib.getExe pkgs.jq} -r '.name')
      ${grim} -o "$OUTPUT" - \
        | ${lib.getExe pkgs.satty} --filename - \
            --fullscreen \
            --initial-tool crop \
            --copy-command ${wlCopy} \
            --output-filename "$FILE"
    '';
  in {
    # Action first, then capture scope
    "Mod+Shift+S".action = sh "${mkMenu [
      {
        key = "s";
        desc = "Save and copy to clipboard";
        cmd = saveScopeMenu;
      }
      {
        key = "c";
        desc = "Clipboard only";
        cmd = clipboardScopeMenu;
      }
      {
        key = "f";
        desc = "Open with Flameshot";
        cmd = flameshotGui;
      }
      {
        key = "e";
        desc = "Capture and crop with Satty";
        cmd = sattyEdit;
      }
    ]}";

    # Native niri screenshot shortcuts
    "Mod+Ctrl+S".action.screenshot-window = [];
    "Mod+Ctrl+Shift+S".action.screenshot-screen = [];
  };
}
