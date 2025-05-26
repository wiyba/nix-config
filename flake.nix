{
  description = "nixos & home-manager configuration files by wiyba";

  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url   = "github:nix-community/home-manager";
    flake-utils.url    = "github:numtide/flake-utils";
    nix-darwin.url     = "github:LnL7/nix-darwin";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, nix-darwin, home-manager, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      nixosHosts  = [ "ms-7c39" "nix-usb" "thinkpad-x1" ];
      darwinHosts = [ "apple-computer" ];
    in
    flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        nixosConfigurations = nixpkgs.lib.genAttrs nixosHosts (host:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./system/configuration.nix
              ./system/machines/${host}/default.nix
              { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
            ];
            specialArgs = { inherit inputs; };
          });

        darwinConfigurations = nixpkgs.lib.genAttrs darwinHosts (host:
          nix-darwin.lib.darwinSystem {
            inherit system;
            modules = [
              ./system/darwin.nix
              ./system/machines/${host}/default.nix
              { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
            ];
            specialArgs = { inherit inputs; };
          });

        homeConfigurations = import ./home/default.nix {
          inherit inputs pkgs system;
          extraHomeConfig = {};
        };
      in {
        inherit nixosConfigurations darwinConfigurations homeConfigurations;
      });
}