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

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    hyst-panel = {
      url = "github:wiyba/hyst-panel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xcli = {
      url = "github:wiyba/xcli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      overlays = [
        inputs.nur.overlays.default
        (import ./overlays)
      ];

      mkSystem =
        {
          host,
          system,
          base,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (base + "/configuration.nix")
            (base + "/machines/${host}")
            ./secrets
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            inputs.sops-nix.nixosModules.sops
            { nix.registry.nixpkgs.flake = nixpkgs; }
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = { inherit inputs host; isServer = base == ./server; };
        };

      mkRpi =
        {
          host,
          system,
          base,
        }:
        inputs.nixos-raspberrypi.lib.nixosSystem {
          modules = [
            (base + "/configuration.nix")
            (base + "/machines/${host}")
            ./secrets
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            inherit inputs host;
            inherit (inputs) nixos-raspberrypi;
            isServer = true;
          };
        };
    in
    {
      nixosConfigurations = {
        home = mkSystem {
          host = "home";
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
        moscow = mkSystem {
          host = "moscow";
          system = "x86_64-linux";
          base = ./server;
        };
        relay = mkSystem {
          host = "relay";
          system = "x86_64-linux";
          base = ./server;
        };
        rpi5 = mkRpi {
          host = "rpi5";
          system = "aarch64-linux";
          base = ./server;
        };
      };
    };
}
