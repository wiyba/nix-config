{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";

    initContent = ''
      command_not_found_handler() { return 127 }
      source ${./headline.zsh-theme}
      bindkey '^ ' autosuggest-accept
    '';

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      c = "clear";
      l = "${pkgs.eza}/bin/eza -lh --icons=auto";
      ls = "${pkgs.eza}/bin/eza -1 --icons=auto";
      ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "${pkgs.eza}/bin/eza -lhD --icons=auto";
      lt = "${pkgs.eza}/bin/eza --icons=auto --tree";
      up = "nix flake update --flake /etc/nixos";
      switch-nixos = "sudo nixos-rebuild switch --flake /etc/nixos#";
      switch-home = "home-manager switch --flake /etc/nixos#home";

      ssh = "TERM=xterm-256color ssh";
    };
  };
}
