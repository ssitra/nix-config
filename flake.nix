{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    # caddy-patched.url = "github:strideynet/nixos-caddy-patched/main";
    # caddy-patched.inputs.nixpkgs.follows = "nixpkgs"; 
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:{
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    nixosConfigurations = {
      homelab = nixpkgs.lib.nixosSystem {
        system = "x86-64-linux";
        specialArgs = {inherit inputs self;};
        modules = [
          ./machines/homelab/configuration.nix
          sops-nix.nixosModules.sops
          # inputs.home-manager.nixosModules.default
        ];
      };
      topper = nixpkgs.lib.nixosSystem {
        system = "x86-64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./machines/homelab/configuration.nix
          sops-nix.nixosModules.sops
          # inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
