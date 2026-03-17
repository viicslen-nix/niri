{
  osConfig,
  config,
  pkgs,
  lib,
  niriLib,
  ...
}: let
  cfg = osConfig.modules.desktop.niri;
  inherit (niriLib) mkRecordCmd mkMenu;
in {
  programs.niri.settings.binds = with lib;
  with config.lib.niri.actions; let
    sh = spawn "sh" "-c";
  in {
    "Mod+Shift+R".action = sh "${mkMenu [
      {
        key = "q";
        desc = "Stop recording";
        cmd = "pkill -INT wl-screenrec";
      }
      {
        key = "a";
        desc = "All monitors";
        cmd = mkRecordCmd "";
      }
      {
        key = "m";
        desc = "Single monitor";
        cmd = mkRecordCmd "-o $(niri msg -j outputs | ${lib.getExe pkgs.jq} -r '.[].name' | ${lib.getExe pkgs.wofi} --dmenu)";
      }
      {
        key = "w";
        desc = "Single window";
        cmd = mkRecordCmd "-g \"$(niri msg -j focused-window | ${lib.getExe pkgs.jq} -r '\"\\(.geometry.x),\\(.geometry.y) \\(.geometry.width)x\\(.geometry.height)\"')\"";
      }
      {
        key = "r";
        desc = "Region";
        cmd = mkRecordCmd "-g \"$(${lib.getExe pkgs.slurp})\"";
      }
    ]}";
  };
}
