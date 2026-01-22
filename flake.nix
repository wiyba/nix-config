{
  description = "nixos & home-manager configs by wiyba";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.3";
    lazyvim.url = "github:pfassina/lazyvim-nix";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lazyvim.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      flake-utils,
      ...
    }@inputs:
    let
      overlays = [
        inputs.nur.overlays.default
      ];

      pkgsFor =
        system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

      mkNixos =
        { host, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
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
      mkServer =
        { host, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./server/configuration.nix
            ./server/machines/${host}
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops

            { nix.registry.nixpkgs.flake = nixpkgs; }
            { nixpkgs.overlays = overlays; }
          ];
          specialArgs = { inherit inputs host; };
        };
 
      mkHome =
        { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          inherit modules;
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit inputs; };
        };
    in
    (flake-utils.lib.eachDefaultSystem (system: {
      formatter = (pkgsFor system).nixfmt;
    }))
    // {
      nixosConfigurations = {
        ms-7c39 = mkNixos {
          host = "ms-7c39";
          system = "x86_64-linux";
        };
        nix-usb = mkNixos {
          host = "nix-usb";
          system = "x86_64-linux";
        };
        thinkpad = mkNixos {
          host = "thinkpad";
          system = "x86_64-linux";
        };
        server = mkServer {
          host = "server";
          system = "x86_64-linux";
        }; 
      };

      homeConfigurations = {
        server = mkHome {
          system = "x86_64-linux";
          modules = [
            ./server/home/home.nix
            inputs.sops-nix.homeManagerModules.sops
            inputs.lazyvim.homeManagerModules.default
          ];
        };
      };
    };
}
