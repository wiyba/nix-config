{
	description = "nixos & home-manager configuration files by wiyba";

	nixConfig = {
	};

	inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    nixosConfigurations =
      inputs.nixpkgs.lib.mergeAttrsList (map
        (host: {
          ${host} = inputs.nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = { inherit inputs; };
            modules = [
              ./system/configuration.nix
              ./system/machine/${host}/default.nix
              { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
            ];
          };
        })
        [ "nix-usb" "ms-7c39" "thinkpad-x1"]
      );

    homeConfigurations =
      import ./home/default.nix {
        inherit inputs pkgs system;
        extraHomeConfig = {};
      };

  in {
    inherit nixosConfigurations homeConfigurations;
  };
}
