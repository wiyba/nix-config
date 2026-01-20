{ lib, ... }:

with lib.hm.gvariant;

{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/nemo/preferences" = {
        show-hidden-files = false;
        default-folder-viewer = "icon-view";
        sort-directories-first = true;
        show-directory-item-counts = "local-only";
        click-policy = "single";
        show-open-in-terminal = true;
        show-run-in-terminal = true;
        date-format = "regular";
      };

      "org/nemo/window-state" = {
        initial-size = mkTuple [
          500
          400
        ];
        maximized = false;
        sidebar-width = 200;
        start-with-sidebar = true;
      };

      "org/nemo/icon-view" = {
        default-zoom-level = "standard";
      };

      "org/gtk/settings/file-chooser" = {
        window-position = mkTuple [
          (-1)
          (-1)
        ];
        window-size = mkTuple [
          300
          100
        ];
      };

      "org/gtk/gtk4/settings/file-chooser" = {
        date-format = "regular";
        location-mode = "path-bar";
        show-hidden = false;
        show-size-column = true;
        show-type-column = true;
        sidebar-width = 263;
        sort-column = "name";
        sort-directories-first = true;
        sort-order = "ascending";
        type-format = "category";
        window-size = mkTuple [
          100
          100
        ];
      };
    };
  };
}
