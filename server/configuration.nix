{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./sops
    ./services/hysteria
    ./services/remnanode
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
    };
  };

  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      vim
      micro
      curl
      git
      wget
    ];

    variables = {
      SOPS_AGE_KEY_FILE = "/etc/nixos/keys/sops-age.key";
    };
  };

  console.keyMap = "us";

  programs.zsh.enable = true;
  users.users.root.shell = pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
    users.root = import ./home/home.nix;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "root"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };
  nixpkgs.config.allowUnfree = true;
}
