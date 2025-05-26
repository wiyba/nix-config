{
  description = "nixos & home-manager configs by wiyba";

  nixConfig = {
    substituters          = [ "https://cache.nixos.org" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url           = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url      = "github:nix-community/home-manager";
    nix-darwin.url        = "github:LnL7/nix-darwin";
    flake-utils.url       = "github:numtide/flake-utils";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";

    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        hosts = {
          ms-7c39        = "x86_64-linux";
          nix-usb        = "x86_64-linux";
          thinkpad-x1    = "x86_64-linux";
          apple-computer = "aarch64-darwin";
        };

        mkNixosSystem = host:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./system/configuration.nix
              ./system/machines/${host}
              home-manager.nixosModules.home-manager
              { nix.registry.nixpkgs.flake = nixpkgs; }
            ];
            specialArgs = { inherit inputs; };
          };

        mkDarwinSystem = host:
          nix-darwin.lib.darwinSystem {
            inherit system;
            modules = [
              ./system/darwin.nix
              ./system/machines/${host}
              home-manager.darwinModules.home-manager
              { nix.registry.nixpkgs.flake = nixpkgs; }
            ];
            specialArgs = { inherit inputs; };
          };

        mkHome = { system, modules }:
          home-manager.lib.homeManagerConfiguration {
            inherit modules;
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            extraSpecialArgs = { inherit inputs; };
          };

      in {
        nixosConfigurations =
          nixpkgs.lib.mapAttrs (name: _: mkNixosSystem name)
            (nixpkgs.lib.filterAttrs (_: arch: arch == "x86_64-linux" || arch == "aarch64-linux") hosts);

        darwinConfigurations =
          nixpkgs.lib.mapAttrs (name: _: mkDarwinSystem name)
            (nixpkgs.lib.filterAttrs (_: arch: arch == "x86_64-darwin" || arch == "aarch64-darwin") hosts);

        homeConfigurations = {
          "wiyba@hyprland" = mkHome {
            system  = "x86_64-linux";
            modules = [ ./home/wm/hyprland/home.nix ];
          };

          "wiyba@darwin" = mkHome {
            system  = "aarch64-darwin";
            modules = [ ./home/wm/darwin/home.nix ];
          };
        };

        formatter = pkgs.alejandra;
      });
}
