{
  description = "Niri desktop environment configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-cli = {
      url = "github:AvengeMedia/danklinux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    niri-flake,
    dankMaterialShell,
    dgop,
    dms-cli,
    ...
  }: {
    # Main NixOS module output - exposes the niri desktop environment configuration
    nixosModules.default = {
      config,
      lib,
      pkgs,
      options,
      ...
    }:
      import ./default.nix {
        inherit config lib pkgs options inputs;
      };

    # Alias for clarity
    nixosModules.niri = self.nixosModules.default;

    # Checks for the module
    checks.x86_64-linux.default = let
      user = "test";
      stateVersion = "25.11";
      home-manager = builtins.fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/release-${stateVersion}.tar.gz";
        sha256 = "sha256:14myi8v2gclsczqri3wvqz0djg48w6h9x6z183xgcinc31qv4mh7";
      };
      testConfig = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          (import "${home-manager}/nixos")
          ({pkgs, ...}: {
            system.stateVersion = stateVersion;
            fileSystems."/".device = "/dev/null";
            boot.loader = {
              grub.enable = false;
              generic-extlinux-compatible.enable = true;
            };

            users.users.${user}.isNormalUser = true;
            home-manager.users.${user}.home.stateVersion = stateVersion;

            modules.desktop.niri = {
              enable = true;
              terminal = pkgs.hello;
              browser = pkgs.hello;
              editor = pkgs.hello;
              fileManager = pkgs.hello;
              passwordManager = pkgs.hello;
            };
          })
        ];
      };
    in
      testConfig.config.system.build.toplevel;
  };
}
