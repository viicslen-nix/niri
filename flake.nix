{
  description = "Niri desktop environment configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    viicslen-lib = {
      url = "github:viicslen-nix/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-unstable = {
      url = "github:YaLTeR/niri";
      flake = false;
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        niri-unstable.follows = "niri-unstable";
      };
    };

    niri-scratchpad = {
      url = "github:argosnothing/niri-scratchpad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
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
      import ./config {
        inherit config lib pkgs options inputs;
      };

    # Alias for clarity
    nixosModules.niri = self.nixosModules.default;

    checks.x86_64-linux.default = let
      user = "test";
      stateVersion = "26.05";
      # Pin a commit, not a branch: a branch tarball's sha256 goes stale on the next push.
      home-manager = fetchTarball {
        url = "https://github.com/nix-community/home-manager/archive/2c0350c759688177331b8f5242311fae8877bdb3.tar.gz";
        sha256 = "sha256:14lbbilvbjhq7bqbjgvm9mvx0ci2sgg3km8whkpncrwygmvhkp5z";
      };
      testConfig = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          (import "${home-manager}/nixos")
          ({pkgs, ...}: {
            system.stateVersion = stateVersion;
            fileSystems."/" = {
              device = "/dev/null";
              fsType = "ext4";
            };
            boot.loader = {
              grub.enable = false;
              generic-extlinux-compatible.enable = true;
            };

            home-manager.useGlobalPkgs = true;

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
      # Keep unsafeDiscardOutputDependency: a bare drvPath's deep context makes the check build the whole system.
      nixpkgs.legacyPackages.x86_64-linux.writeText "niri-module-eval"
      (builtins.unsafeDiscardOutputDependency testConfig.config.system.build.toplevel.drvPath);
  };
}
