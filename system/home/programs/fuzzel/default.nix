{ ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        use-bold = true;
        line-height = 25;
        fields = "name,generic,comment,categories,filename,keywords";
        terminal = "kitty";
        prompt = "'> '";
        layer = "top";
        lines = 10;
        width = 35;
        horizontal-pad = 25;
        inner-pad = 5;
        dpi-aware = false;
      };
      border = {
        radius = 15;
        width = 3;
      };
      colors = {
        background = "282828ff";
        text = "ebdbb2ff";
        selection = "504945ff";
        selection-text = "fbf1c7ff";
        border = "928374ff";
        match = "fe8019ff";
        selection-match = "fabd2fff";
      };
    };
  };
}
