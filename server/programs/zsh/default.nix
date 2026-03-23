{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    interactiveShellInit = ''
      command_not_found_handler() { return 127 }
      nh() {
        if [[ "$1" == "os" && "$2" == "switch" ]]; then
	  command nh "$@" -R
	else
	  command nh "$@"
	fi
      }
      source ${./headline.zsh-theme}
      bindkey '^ ' autosuggest-accept
    '';

    shellAliases = {
      c = "clear";
      l = "${pkgs.eza}/bin/eza -lh --icons=auto";
      ls = "${pkgs.eza}/bin/eza -1 --icons=auto";
      ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "${pkgs.eza}/bin/eza -lhD --icons=auto";
      lt = "${pkgs.eza}/bin/eza --icons=auto --tree";
      up = "nix flake update --flake /etc/nixos";

      ssh = "TERM=xterm-256color ssh";
    };
  };
}
