{
  lib,
  config,
  ...
}: let
  # Raw KDL for layer-rules using background-effect, which upstream schema
  # doesn't support yet (compatibility shim until it lands in niri-flake).
  backgroundEffectRules = ''
    layer-rule {
      match at-startup=true namespace="^dms:.*"
      background-effect {
        blur true
        xray true
      }
    }
    layer-rule {
      match at-startup=true namespace="^dev.zed.Zed$"
      background-effect {
        blur true
        xray true
      }
    }
  '';
in {
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
    ];

    layer-rules = [
      {
        matches = [{namespace = "dms:blurwallpaper";}];
        place-within-backdrop = true;
      }
    ];
  };

  # Write background-effect rules as a separate KDL file to be included by DMS.
  # DMS includes files from the niri/dms/ subdirectory.
  xdg.configFile."niri/dms/background-effect.kdl" = lib.mkIf (config.programs.niri.finalConfig != null) {
    text = backgroundEffectRules;
  };
}

