{
  description = "nixos & home-manager configs by wiyba";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    { nixpkgs, ... } @ inputs:
    let
      overlays = [
        inputs.nur.overlays.default
        (import ./overlays)
      ];

      mkSystem =
        { host, system, base }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (base + "/configuration.nix")
            (base + "/machines/${host}")
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            inputs.sops-nix.nixosModules.sops
            { nix.registry.nixpkgs.flake = nixpkgs; }
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = { inherit inputs host; };
        };
    in
    {
      nixosConfigurations = {
        desktop = mkSystem {
          host = "desktop";
          system = "x86_64-linux";
          base = ./system; 
        };
        thinkpad = mkSystem {
          host = "thinkpad";
          system = "x86_64-linux";
          base = ./system;
        };
        stockholm = mkSystem {
          host = "stockholm";
          system = "x86_64-linux";
          base = ./server;
        };
	london = mkSystem {
	  host = "london";
	  system = "x86_64-linux";
	  base = ./server;
	};
      };
    };
}
