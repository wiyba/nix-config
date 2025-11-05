{
  description = "nixos & home-manager configs by wiyba";

  inputs = {
    nixpkgs.url      = "nixpkgs/nixos-unstable";
    nur.url          = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url   = "github:LnL7/nix-darwin";
    flake-utils.url  = "github:numtide/flake-utils";

    #nixpkgs fixed
    #clash-verge.url  = "github:NixOS/nixpkgs/9e83b64f727c88a7711a2c463a7b16eedb69a84c";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";

    grub-themes.url = "github:jeslie0/nixos-grub-themes";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, nur, home-manager, nix-darwin, flake-utils, ... } @ inputs:
    let
      overlays = [ 
        nur.overlays.default
      ];

      hosts = {
        ms-7c39        = "x86_64-linux";
        nix-usb        = "x86_64-linux";
        thinkpad       = "x86_64-linux";
        apple-computer = "aarch64-darwin";
      };

     pkgsFor = system: import nixpkgs { inherit system overlays; config = { allowUnfree = true; }; }; 

      mkNixosSystem = host: nixpkgs.lib.nixosSystem {
        system  = hosts.${host};
        modules = [
          ./system/configuration.nix
          ./system/machines/${host}
          home-manager.nixosModules.home-manager

          { nixpkgs.config = { allowUnfree = true; }; }
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
          home-manager.darwinModules.home-manager

          { nixpkgs.config = { allowUnfree = true; }; }
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
        base = mkHome {
          system  = "x86_64-linux";
          modules = [ 
            ./home/base
            inputs.sops-nix.homeManagerModules.sops
          ];
        };
        hyprland = mkHome {
          system  = "x86_64-linux";
          modules = [ 
            ./home/base
            ./home/hyprland
            inputs.sops-nix.homeManagerModules.sops
          ];
        };
        darwin = mkHome {
          system  = "aarch64-darwin";
          modules = [ ./home/wm/darwin/home.nix ];
        };
      };
    };
}
