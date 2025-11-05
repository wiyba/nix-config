{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    initContent = ''
      setopt HIST_FIND_NO_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt SHARE_HISTORY
      HISTFILE=~/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000

      source ${./headline.zsh-theme}
    '';

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "zdharma-continuum/fast-syntax-highlighting"; }
        { name = "marlonrichert/zsh-autocomplete"; }
      ];
    };

    shellAliases = {
			c  = "clear";
			l  = "${pkgs.eza}/bin/eza -lh --icons=auto";
			ls = "${pkgs.eza}/bin/eza -1 --icons=auto";
			ll = "${pkgs.eza}/bin/eza -lha --icons=auto --sort=name --group-directories-first";
			ld = "${pkgs.eza}/bin/eza -lhD --icons=auto";
			lt = "${pkgs.eza}/bin/eza --icons=auto --tree";
			cat = "bat";
		}; 
  };
}

