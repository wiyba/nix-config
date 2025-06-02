{ ... }:

{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        # type = "none";
        type   = "kitty";
        source = "${./nixos2.png}";
        padding = { top = 0; right = 6; };
        width  = 25;
        height = 13;
        color  = { "1" = "white"; };
        # source = "${./cat}"; # cat
      };

      display = { separator = " •  "; };

      modules = [
        { type = "title"; color = { user = "33"; at = "37"; host = "33"; }; }
        "break"
        { type = "os";      key = "distribution   "; keyColor = "33"; }
        { type = "kernel";  key = "linux kernel   "; keyColor = "33"; }
        { type = "packages"; format = "{} (nix)"; key = "packages       "; keyColor = "33"; }
        { type = "shell";   key = "unix shell     "; keyColor = "33"; }
        { type = "terminal"; key = "terminal       "; keyColor = "33"; }
        { type = "wm";      format = "{} ({3})"; key = "window manager "; keyColor = "33"; }
        "break"
        { type = "uptime";  key = "uptime         "; keyColor = "33"; }
        {
          type = "command";
          key  = "os age         ";
          keyColor = "33";
          text = ''
            birth_install=$(stat -c %W /)
            current=$(date +%s)
            days=$(( (current - birth_install) / 86400 ))
            echo "$days days"
          '';
        }
        "break"
        { type = "colors"; symbol = "circle"; }
        "break"
        "break"
      ];
    };
  };
}
