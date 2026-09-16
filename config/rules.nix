{
  programs.niri.settings = {
    window-rules = [
      {
        geometry-corner-radius = let
          r = 8.0;
        in {
          top-left = r;
          top-right = r;
          bottom-left = r;
          bottom-right = r;
        };
        clip-to-geometry = true;
        draw-border-with-background = false;
      }
      {
        matches = [{app-id = "ferdium";}];
        default-column-width = {proportion = 0.5;};
        open-floating = true;
        open-focused = true;
        tiled-state = true;
        block-out-from = "screencast";
        default-floating-position = {
          relative-to = "right";
          x = 16;
          y = 0;
        };
      }
      {
        # Match the title, not app-id: flameshot's capture overlay has an empty app-id.
        matches = [{title = "^flameshot$";}];
        open-floating = true;
        open-fullscreen = true;
      }
      {
        matches = [{app-id = "^com\\.gabm\\.satty$";}];
        open-floating = true;
        open-fullscreen = true;
      }
    ];

    layer-rules = [
      {
        matches = [{namespace = "dms:blurwallpaper";}];
        place-within-backdrop = true;
      }
    ];
  };
}
