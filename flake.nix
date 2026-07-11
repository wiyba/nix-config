{
  description = "nixos & home-manager configs by wiyba";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.thalheim.io"
      "https://noctalia.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://zed.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    xcli = {
      url = "github:wiyba/xcli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wba-website.url = "github:wiyba/website";

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nsticky = {
      url = "github:lonerOrz/nsticky";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      overlays = [
        inputs.nur.overlays.default
        inputs.claude-code-nix.overlays.default
        (import ./overlays)
      ];

      mkSystem =
        { host
        , system
        , base
        , wm ? null
        ,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (base + "/configuration.nix")
            (base + "/machines/${host}")
            ./secrets
            ./proxy
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            inputs.sops-nix.nixosModules.sops
            { nix.registry.nixpkgs.flake = nixpkgs; }
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = {
            inherit inputs host wm;
            isServer = base == ./server;
          };
        };

      mkRpi =
        { host
        , base
        ,
        }:
        inputs.nixos-raspberrypi.lib.nixosSystem {
          modules = [
            (base + "/configuration.nix")
            (base + "/machines/${host}")
            ./secrets
            ./proxy
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
          wm = "niri";
        };
        thinkpad = mkSystem {
          host = "thinkpad";
          system = "x86_64-linux";
          base = ./system;
          wm = "niri";
        };
        stockholm = mkSystem {
          host = "stockholm";
          system = "x86_64-linux";
          base = ./server;
        };
        helsinki = mkSystem {
          host = "helsinki";
          system = "x86_64-linux";
          base = ./server;
        };
        almaty = mkSystem {
          host = "almaty";
          system = "x86_64-linux";
          base = ./server;
        };
        nest = mkRpi {
          host = "nest";
          base = ./server;
        };
      };
    };
}
