{
  description = "nixos & home-manager configs by wiyba";

  nixConfig = {
    substituters          = [ "https://cache.nixos.org" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url   = "github:LnL7/nix-darwin";
    flake-utils.url  = "github:numtide/flake-utils";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";
    
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, flake-utils, agenix, ... } @ inputs:
    let
      hosts = {
        ms-7c39        = "x86_64-linux";
        nix-usb        = "x86_64-linux";
        thinkpad-x1    = "x86_64-linux";
        apple-computer = "aarch64-darwin";
      };

      pkgsFor = system: import nixpkgs { inherit system; config.allowUnfree = true; };

      mkNixosSystem = host: nixpkgs.lib.nixosSystem {
        system  = hosts.${host};
        modules = [
          ./system/configuration.nix
          ./system/machines/${host}
          home-manager.nixosModules.home-manager
          { nix.registry.nixpkgs.flake = nixpkgs; }
        ];
        specialArgs = { inherit inputs host; };
      };

      mkDarwinSystem = host: nix-darwin.lib.darwinSystem {
        system  = hosts.${host};
        modules = [
          ./system/darwin.nix
          ./system/machines/${host}
          home-manager.darwinModules.home-manager
          { nix.registry.nixpkgs.flake = nixpkgs; }
        ];
        specialArgs = { inherit inputs host; };
      };

      mkHome = { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          inherit modules;
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit inputs agenix; };
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
        hyprland = mkHome {
          system  = "x86_64-linux";
          modules = [ 
            agenix.homeManagerModules.default
            ./home/wm/hyprland/home.nix
          ];
        };
        darwin = mkHome {
          system  = "aarch64-darwin";
          modules = [ ./home/wm/darwin/home.nix ];
        };
      };
    };
}
