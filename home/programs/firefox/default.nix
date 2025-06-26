{ pkgs, config, ... }:

let
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    bitwarden
    darkreader
    ff2mpv
    # auto-accepts cookies, use only with privacy-badger & ublock-origin
    istilldontcareaboutcookies
    languagetool
    link-cleaner
    privacy-badger
    ublock-origin
  ];

  # disable the annoying floating icon with camera and mic when on a call
  disableWebRtcIndicator = ''
    #webrtcIndicator {
      display: none;
    }
  '';

  userChrome = disableWebRtcIndicator;

  # ~/.mozilla/firefox/PROFILE_NAME/prefs.js | user.js
  settings = {
    "app.normandy.first_run" = false;
    "app.shield.optoutstudies.enabled" = false;

    # disable updates (pretty pointless with nix)
    "app.update.channel" = "default";

    "browser.contentblocking.category" = "standard"; # "strict"
    "browser.ctrlTab.recentlyUsedOrder" = false;

    "browser.download.useDownloadDir" = false;
    "browser.download.viewableInternally.typeWasRegistered.svg" = true;
    "browser.download.viewableInternally.typeWasRegistered.webp" = true;
    "browser.download.viewableInternally.typeWasRegistered.xml" = true;

    "browser.search.region" = "RU";
    "browser.search.widget.inNavBar" = true;

    "browser.shell.checkDefaultBrowser" = false;
    "browser.tabs.loadInBackground" = true;
    "browser.urlbar.placeholderName" = "Google";
    "browser.urlbar.showSearchSuggestionsFirst" = false;

    # disable all the annoying quick actions
    "browser.urlbar.quickactions.enabled" = false;
    "browser.urlbar.quickactions.showPrefs" = false;
    "browser.urlbar.shortcuts.quickactions" = false;
    "browser.urlbar.suggest.quickactions" = false;

    "browser.startup.homepage_override.mstone" = "ignore";
    "browser.aboutwelcome.enabled" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;

    "distribution.searchplugins.defaultLocale" = "en-US";

    "doh-rollout.balrog-migration-done" = true;
    "doh-rollout.doneFirstRun" = true;

    "dom.forms.autocomplete.formautofill" = false;

    "general.autoScroll" = true;
    "general.useragent.locale" = "ru-RU";

    "extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";

    "extensions.extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
    "extensions.update.enabled" = false;
    "extensions.webcompat.enable_picture_in_picture_overrides" = true;
    "extensions.webcompat.enable_shims" = true;
    "extensions.webcompat.perform_injections" = true;
    "extensions.webcompat.perform_ua_overrides" = true;

    "print.print_footerleft" = "";
    "print.print_footerright" = "";
    "print.print_headerleft" = "";
    "print.print_headerright" = "";

    "privacy.donottrackheader.enabled" = true;

    # Yubikey
    "security.webauth.u2f" = true;
    "security.webauth.webauthn" = true;
    "security.webauth.webauthn_enable_softtoken" = true;
    "security.webauth.webauthn_enable_usbtoken" = true;

    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    
    "browser.startup.homepage" = "https://wiyba.org/startpage";
    
    # No session restore
    "browser.sessionstore.resume_from_crash" = false;
    "browser.sessionstore.max_resumed_crashes" = 0;
    
    # No sponsored suggestions
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.quicksuggest.enabled" = false;
    
    "privacy.sanitize.sanitizeOnShutdown" = true;
    "privacy.sanitize.pending" = ''[{"id":"shutdown","itemsToClear":["formdata","browsingHistoryAndDownloads"],"options":{}}]'';
    "browser.bookmarks.file" = "";
    "privacy.clearOnShutdown_v2.siteSettings" = false;
    "privacy.clearOnShutdown_v2.cache" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    
    # urlbar suggestions
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.topsites" = false;
    "browser.urlbar.suggest.engines" = false;

    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.toolbars.bookmarks.visibility" = "never";

    "browser.urlbar.trimURLs" = false;
    "browser.urlbar.trimHttps" = false;
    "browser.tabs.closeWindowWithLastTab" = false;
    "browser.aboutConfig.showWarning" = false;

    "signon.rememberSignons" = false;
    "signon.autofillForms" = false;
    "signon.generation.enabled" = false;
    "signon.management.page.breach-alerts.enabled" = false;

    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

    "intl.accept_languages" = "ru-RU, ru, en-US, en";
  };
in
{
  programs.firefox = {
    enable = true;

    package = pkgs.firefox-beta;

    profiles = {
      default = {
        id = 0;
        extensions.packages = extensions;
        inherit settings userChrome;
      };
    };

    policies = {
      ExtensionSettings = {
        "*" = {
          installation_mode = "allowed";
          run_in_private_windows = "allow";
        };
      };
    };
  };
}

