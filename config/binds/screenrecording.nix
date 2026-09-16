{
  osConfig,
  config,
  pkgs,
  lib,
  niriLib,
  ...
}: let
  inherit (niriLib) mkRecordCmd mkMenu;

  niri = lib.getExe osConfig.programs.niri.package;
  jq = lib.getExe pkgs.jq;
in {
  programs.niri.settings.binds = with lib;
  with config.lib.niri.actions; let
    sh = spawn "sh" "-c";
  in {
    "Mod+Shift+R".action = sh "${mkMenu [
      {
        key = "q";
        desc = "Stop recording";
        cmd = "${getExe' pkgs.procps "pkill"} -INT wl-screenrec";
      }
      {
        # Keep -o: with no -o/-g, wl-screenrec bails on multi-monitor setups.
        key = "a";
        desc = "Focused monitor";
        cmd = mkRecordCmd ''-o "$(${niri} msg -j focused-output | ${jq} -r .name)"'';
      }
      {
        key = "m";
        desc = "Single monitor";
        cmd = mkRecordCmd ''-o "$(${niri} msg -j outputs | ${jq} -r '.[] | select(.logical != null) | .name' | ${getExe pkgs.wofi} --dmenu)"'';
      }
      {
        key = "r";
        desc = "Region";
        cmd = mkRecordCmd ''-g "$(${getExe pkgs.slurp})"'';
      }
    ]}";
  };
}
