{ pkgs, ... }:

{
  imports = [ inputs.zen-nebula.homeModules.default ];
  zen-nebula = {
    enable = true;
    profile = "profile";
  };

  home.file.".mozilla/firefox/profiles.ini".text = ''
  [Profile0]
  Name=profile
  IsRelative=1
  Path=profile
  Default=1

  [General]
  StartWithLastProfile=1
  Version=2
  '';

  home.file.".mozilla/firefox/profile/prefs.js".text = ''
  user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  user_pref("browser.sessionstore.resume_from_crash", false);
  user_pref("browser.sessionstore.enabled", false);
  user_pref("browser.sessionstore.max_tabs_undo", 0);
  user_pref("browser.sessionstore.max_windows_undo", 0);
  '';
}

