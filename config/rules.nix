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
        # Flameshot's capture overlay is a normal toplevel with an empty
        # app-id, so match on its title. Let it float fullscreen instead of
        # becoming a tile in the workspace.
        matches = [{title = "^flameshot$";}];
        open-floating = true;
        open-fullscreen = true;
      }
      {
        # Same treatment for satty's editor: float fullscreen so it overlays
        # instead of pushing the tiled layout around.
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
