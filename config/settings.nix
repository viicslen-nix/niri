{
  lib,
  pkgs,
  ...
}: {
  programs.niri.settings = {
    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;
    screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H%M%S.png";
    xwayland-satellite.path = "${lib.getExe pkgs.xwayland-satellite}";

    cursor = {
      hide-when-typing = true;
      hide-after-inactive-ms = 2000;
    };

    input = {
      warp-mouse-to-focus = {
        enable = true;
        mode = "center-xy";
      };

      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };

      keyboard.xkb.options = "compose:rwin";
    };

    layout = {
      gaps = 16;
      border.width = 4;
      always-center-single-column = true;

      preset-column-widths = [
        {proportion = 0.3;}
        {proportion = 0.48;}
        {proportion = 0.65;}
        {proportion = 0.95;}
      ];

      default-column-width = {proportion = 0.95;};

      preset-window-heights = [
        {proportion = 0.4;}
        {proportion = 0.5;}
        {proportion = 0.6;}
      ];
    };

    spawn-at-startup = [
      {argv = ["${pkgs.gnome-keyring}/bin/gnome-keyring-daemon" "--start" "--components=secrets"];}
      {sh = "systemctl --user start dms-session.target";}
    ];
  };
}
