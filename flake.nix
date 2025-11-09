{
  description = "nixos & home-manager configs by wiyba";

  inputs = {
    nixpkgs.url      = "nixpkgs/nixos-unstable";
    nur.url          = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url   = "github:LnL7/nix-darwin";
    flake-utils.url  = "github:numtide/flake-utils";
    grub-themes.url  = "github:jeslie0/nixos-grub-themes";
    sops-nix.url     = "github:Mic92/sops-nix";
    lanzaboote.url   = "github:nix-community/lanzaboote/v0.4.3";
    lazyvim.url      = "github:pfassina/lazyvim-nix";
 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows     = "nixpkgs";
    lanzaboote.inputs.nixpkgs.follows   = "nixpkgs";
    lazyvim.inputs.nixpkgs.follows      = "nixpkgs";
    grub-themes.inputs.nixpkgs.follows  = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, nix-darwin, ... } @ inputs:
    let
      overlays = [ 
        inputs.nur.overlays.default
      ];

      hosts = {
        ms-7c39        = "x86_64-linux";
        nix-usb        = "x86_64-linux";
        thinkpad       = "x86_64-linux";
        apple-computer = "aarch64-darwin";
      };

      pkgsFor = system: import nixpkgs { inherit system overlays; config.allowUnfree = true; }; 

      mkNixosSystem = host: nixpkgs.lib.nixosSystem {
        system  = hosts.${host};
        modules = [
          ./system/configuration.nix
          ./system/machines/${host}
          inputs.home-manager.nixosModules.home-manager
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.sops-nix.nixosModules.sops

          { nix.registry.nixpkgs.flake = nixpkgs; }
          { nixpkgs.overlays = overlays; }
        ];
        specialArgs = { inherit inputs host; }; 
      };

      mkDarwinSystem = host: nix-darwin.lib.darwinSystem {
        system  = hosts.${host};
        modules = [
          ./system/darwin.nix
          ./system/machines/${host}
          inputs.home-manager.darwinModules.home-manager

          { nix.registry.nixpkgs.flake = nixpkgs; }
          { nixpkgs.overlays = overlays; }
        ];
        specialArgs = { inherit inputs host; };
      };

      mkHome = { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          inherit modules;
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit inputs; };
        };
    in
    (flake-utils.lib.eachDefaultSystem (system: {
      formatter = (pkgsFor system).alejandra;
    }))
    // {
      nixosConfigurations =
        nixpkgs.lib.mapAttrs (n: _: mkNixosSystem n)
          (nixpkgs.lib.filterAttrs (_: a: a == "x86_64-linux" || a == "aarch64-linux") hosts);

      darwinConfigurations =
        nixpkgs.lib.mapAttrs (n: _: mkDarwinSystem n)
          (nixpkgs.lib.filterAttrs (_: a: a == "x86_64-darwin" || a == "aarch64-darwin") hosts);

      homeConfigurations = {
        home = mkHome {
          system  = "x86_64-linux";
          modules = [ 
            ./home/home.nix
            inputs.sops-nix.homeManagerModules.sops
            inputs.lazyvim.homeManagerModules.default
          ];
        };
        darwin = mkHome {
          system  = "aarch64-darwin";
          modules = [ 
            ./home/darwin/home.nix
          ];
        };
      };
    };
}
