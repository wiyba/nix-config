{
  pkgs,
  ...
}:

{
  imports = [
    ./programs/git
    ./programs/ssh
    ./programs/zsh
    ./secrets
    ./services/hysteria
    ./services/remnanode
    ./services/sshd
  ];

  networking.firewall.enable = true;

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
    ];

    variables = {
      SOPS_AGE_KEY_FILE = "/etc/nixos/keys/sops-age.key";
      EDITOR = "vim";
      VISUAL = "vim";
      GIT_ASKPASS = "";
    };
  };

  console.keyMap = "us";

  users.users.root.shell = pkgs.zsh;

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
