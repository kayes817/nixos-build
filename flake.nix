{
  description = "Custom NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations.default = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self;
          inherit inputs;
        };
        modules = [
          ./modules/hosts/default.nix
          ./modules/desktop/general.nix
          ./modules/desktop/gimp.nix
          ./modules/desktop/hyprland.nix
          ./modules/desktop/neovim.nix
          ./modules/tools/rednix.nix

        ];
      };

      nixosModules.default = import ./modules/common.nix;
    };
}
