{
  osConfig,
  config,
  pkgs,
  lib,
  niriLib,
  ...
}: {
  programs.niri.settings.binds = with lib;
  with config.lib.niri.actions; let
    sh = spawn "sh" "-c";

    inherit (niriLib) mkMenu;

    niri = lib.getExe osConfig.programs.niri.package;
    grim = lib.getExe pkgs.grim;
    niriAction = "${niri} msg action";
    envCmd = "${pkgs.coreutils}/bin/env";
    sleep = "${pkgs.coreutils}/bin/sleep";
    wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
    screenshotFile = "$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png";

    mkShotScript = name: body:
      lib.getExe (pkgs.writeShellScriptBin name ''
        set -euo pipefail
        ${body}
      '');

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
            else ''
              ${grim} ${scope.grimArgs} "$FILE"
              ${wlCopy} < "$FILE"
            ''
          }
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
        ${lib.getExe pkgs.flameshot} gui
    '';

    sattyEdit = mkShotScript "niri-shot-satty" ''
      FILE=${screenshotFile}
      mkdir -p "$(dirname "$FILE")"
      OUTPUT=$(${niri} msg -j focused-output \
        | ${lib.getExe pkgs.jq} -r '.name')
      ${grim} -o "$OUTPUT" - \
        | ${lib.getExe pkgs.satty} --filename - \
            --fullscreen \
            --initial-tool crop \
            --copy-command ${wlCopy} \
            --output-filename "$FILE"
    '';
  in {
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

    "Mod+Ctrl+S".action.screenshot-window = [];
    "Mod+Ctrl+Shift+S".action.screenshot-screen = [];
  };
}
