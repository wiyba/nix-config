{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./programs/git
    ./programs/ssh
    ./programs/zsh
    ./services/sshd
  ];

  networking.firewall.enable = lib.mkDefault false;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.tcp_max_syn_backlog" = 4096;
    "net.core.somaxconn" = 4096;
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

  environment = {
    systemPackages = with pkgs; [
      micro
      vim
      curl
      wget
      gh
      btop
      dig
      eza
      age
      sops
      mtr
      jq
      file
      nitch
      claude-code
    ];

    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
      GIT_ASKPASS = "";
    };
  };

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };

  console.keyMap = "us";

  users.users.root.shell = pkgs.zsh;

  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

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
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixos-raspberrypi.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;
}
