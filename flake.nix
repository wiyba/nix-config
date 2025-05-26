{
  description = "nixos & home-manager configuration files by wiyba";

  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url   = "github:nix-community/home-manager";
    flake-utils.url    = "github:numtide/flake-utils";
    nix-darwin.url     = "github:LnL7/nix-darwin";

    # packages not in nixpkgs
    zen-browser.url = "github:MarceColl/zen-browser-flake";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows   = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, flake-utils, nix-darwin, ... }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    nixosHosts  = [ "ms-7c39" "nix-usb" "thinkpad-x1" ];
    darwinHosts = [ "apple-computer" ];
  in
    flake-utils.lib.eachSystem systems (_: { }) // {
      nixosConfigurations = nixpkgs.lib.genAttrs nixosHosts (host:
        nixpkgs.lib.nixosSystem {
          system  = "x86_64-linux";
          modules = [
            ./system/configuration.nix
            ./system/machines/${host}
            { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
          ];
          specialArgs = { inherit inputs; };
        });

      darwinConfigurations = nixpkgs.lib.genAttrs darwinHosts (host:
        nix-darwin.lib.darwinSystem {
          system  = "aarch64-darwin";
          modules = [
            ./system/darwin.nix
            ./system/machines/${host}
            { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
          ];
          specialArgs = { inherit inputs; };
        });

      homeConfigurations = import ./home/default.nix {
        inherit inputs;
        pkgs   = pkgsFor "x86_64-linux";
        system = "x86_64-linux";
      };
    };
}