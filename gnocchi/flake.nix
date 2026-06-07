{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      antigravity-nix,
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {

      nixosConfigurations.gnocchi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Pass flake inputs to modules (so you can use inputs.nixpkgs in other files)
        specialArgs = {
          inherit pkgs-unstable;
          inherit antigravity-nix;
        };

        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen6
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };

    };
}
