{ pkgs, ... }:

{
  home.packages = [ pkgs.hyprpaper ];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    $1 = ${../../../imgs/42271.jpg}
    $2 = ${../../../imgs/new.jpeg}
    $3 = ${../../../imgs/reddit2.png}
    $4 = ${../../../imgs/new.jpeg}
    $5 = ${../../../imgs/img19.jpg}
    $6 = ${../../../imgs/gruvbox-dark-blue.png}

    $current = $6

    preload = $current
    wallpaper = , $current
    splash = false
  '';
}
