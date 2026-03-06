{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware }@inputs: {

    nixosConfigurations.gnocchi = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      # Pass flake inputs to modules (so you can use inputs.nixpkgs in other files)
      specialArgs = { inherit inputs; };
      
      modules = [
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen6
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };

  };
}
