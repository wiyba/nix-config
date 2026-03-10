{ pkgs, ... }:

let
  gruvbox-theme = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
    pname = "gruvboxtheme";
    version = "1.0";
    addonId = "{fd4fdeb0-5a65-4978-81c5-3488d4d56426}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3835316/gruvboxtheme-1.0.xpi";
    sha256 = "04mrmyga4ig6bxlhdy42n56k9al0rqc0qfd7qzf7nvc6qlz9cwzb";
    meta = {};
  };

  extensions = (with pkgs.nur.repos.rycee.firefox-addons; [
    bitwarden
  ]) ++ [ gruvbox-theme ];

  settings = {
    # --- performance ---
    "gfx.webrender.all" = true;
    "layers.acceleration.force-enabled" = true;
    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.force-enabled" = true;
    "browser.cache.disk.enable" = false;
    "browser.cache.memory.enable" = true;
    "browser.cache.memory.capacity" = 524288; # 512MB
    "browser.sessionstore.interval" = 30000;
    "browser.sessionhistory.max_entries" = 10;
    "network.http.max-persistent-connections-per-server" = 10;

    # --- history: off ---
    "places.history.enabled" = false;
    "privacy.sanitize.sanitizeOnShutdown" = true;
    "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
    "privacy.clearOnShutdown_v2.formdata" = true;
    "privacy.clearOnShutdown_v2.siteSettings" = false;
    "privacy.clearOnShutdown_v2.cache" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

    # --- telemetry: off ---
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "app.normandy.enabled" = false;
    "app.normandy.first_run" = false;
    "app.shield.optoutstudies.enabled" = false;
    "beacon.enabled" = false;
    "browser.discovery.enabled" = false;
    "datareporting.policy.firstRunURL" = "";

    # --- network privacy ---
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = true;
    "network.predictor.enabled" = false;
    "browser.send_pings" = false;

    # --- ui ---
    "browser.startup.homepage" = "https://search.wiyba.org";
    "browser.aboutwelcome.enabled" = false;
    "browser.startup.homepage_override.mstone" = "ignore";
    "startup.homepage_welcome_url" = "";
    "startup.homepage_welcome_url.additional" = "";
    "browser.aboutConfig.showWarning" = false;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.ctrlTab.recentlyUsedOrder" = false;
    "browser.tabs.closeWindowWithLastTab" = false;
    "browser.urlbar.trimURLs" = false;
    "browser.urlbar.trimHttps" = false;
    "browser.toolbars.bookmarks.visibility" = "never";
    "general.autoScroll" = true;
    "general.useragent.locale" = "ru-RU";
    "intl.accept_languages" = "ru-RU, ru, en-US, en";

    # --- disable bloat ---
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.contentblocking.category" = "standard";
    "extensions.update.enabled" = false;

    # --- urlbar: only search suggestions ---
    "browser.urlbar.suggest.searches" = true;
    "browser.urlbar.suggest.bookmark" = false;
    "browser.urlbar.suggest.history" = false;
    "browser.urlbar.suggest.openpage" = false;
    "browser.urlbar.suggest.topsites" = false;
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.quicksuggest.enabled" = false;

    # --- forms/autofill: off ---
    "dom.forms.autocomplete.formautofill" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;

    # --- passwords: off (bitwarden) ---
    "signon.rememberSignons" = false;
    "signon.autofillForms" = false;
    "signon.generation.enabled" = false;
    "signon.management.page.breach-alerts.enabled" = false;

    # --- session ---
    "browser.sessionstore.resume_from_crash" = false;
    "browser.sessionstore.max_resumed_crashes" = 0;

    # --- printing ---
    "print.print_footerleft" = "";
    "print.print_footerright" = "";
    "print.print_headerleft" = "";
    "print.print_headerright" = "";

    # --- doh: suppress prompts ---
    "doh-rollout.balrog-migration-done" = true;
    "doh-rollout.doneFirstRun" = true;

    # --- extensions ---
    "extensions.autoDisableScopes" = 0;
    "extensions.activeThemeID" = "{fd4fdeb0-5a65-4978-81c5-3488d4d56426}";
    "extensions.webcompat.enable_picture_in_picture_overrides" = true;
    "extensions.webcompat.enable_shims" = true;
    "extensions.webcompat.perform_injections" = true;
    "extensions.webcompat.perform_ua_overrides" = true;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-beta;

    profiles.default = {
      id = 0;
      extensions.packages = extensions;
      inherit settings;
    };

    policies = {
      NoDefaultBookmarks = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      ExtensionSettings."*" = {
        installation_mode = "allowed";
        run_in_private_windows = "allow";
      };
    };
  };
}
