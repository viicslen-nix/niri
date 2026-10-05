{
  lib,
  pkgs,
  inputs,
  config,
  options,
  ...
}:
with lib; let
  name = "niri";
  namespace = "desktop";

  cfg = config.modules.${namespace}.${name};

  homeManagerLoaded = builtins.hasAttr "home-manager" options;
in {
  options.modules.${namespace}.${name} = {
    enable = mkEnableOption "niri";

    terminal = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default terminal emulator to use for niri keybinds.
        If null, will use the defaults module terminal if available.
      '';
    };

    browser = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default browser to use for niri keybinds.
        If null, will use the defaults module browser if available.
      '';
    };

    editor = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default editor to use for niri keybinds.
        If null, will use the defaults module editor if available.
      '';
    };

    fileManager = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default file manager to use for niri keybinds.
        If null, will use the defaults module fileManager if available.
      '';
    };

    passwordManager = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The default password manager to use for niri keybinds.
        If null, will use the defaults module passwordManager if available.
      '';
    };
  };

  imports = [
    inputs.niri-flake.nixosModules.niri
  ];

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.overlays = [
        inputs.niri-flake.overlays.niri
        # Drop once niri-flake builds against libdisplay-info_0_3; nixpkgs removed 0.2.
        (_final: prev: {
          libdisplay-info_0_2 = prev.libdisplay-info_0_3.overrideAttrs (_: {
            version = "0.2.0";
            src = prev.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "emersion";
              repo = "libdisplay-info";
              tag = "0.2.0";
              hash = "sha256-6xmWBrPHghjok43eIDGeshpUEQTuwWLXNHg7CnBUt3Q=";
            };
          });
        })
      ];

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        adwaita-fonts
        adwaita-qt6
        adwaita-qt
        inputs.niri-scratchpad.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      systemd.user.services.niri-flake-polkit.enable = false;

      xdg.portal = {
        extraPortals = [pkgs.xdg-desktop-portal-wlr];
        config.niri = {
          default = ["gnome" "gtk"];
          # Don't route Screenshot back to gnome: it fails on multi-monitor.
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
      };
    }
    (optionalAttrs homeManagerLoaded {
      home-manager.sharedModules = [
        {_module.args.niriLib = inputs.viicslen-lib.lib.wayland {inherit pkgs lib;};}
        ./settings.nix
        ./rules.nix
        ./binds
      ];
    })
  ]);
}
