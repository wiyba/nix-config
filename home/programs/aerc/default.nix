{ ... }:

{
  programs.aerc = {
    enable = true;

    extraConfig = {
      general.unsafe-accounts-conf = true;
      compose.edit-headers = true;
      filters = {
        "text/plain" = "colorize";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "text/html" = "! html";
        ".headers" = "colorize";
      };
    };

    extraAccounts.personal = {
      source = "imaps://mail%40wiyba.org@mail.wiyba.org:993";
      source-cred-cmd = "cat /run/secrets/mail-account-password";
      outgoing = "smtps://mail%40wiyba.org@mail.wiyba.org:465";
      outgoing-cred-cmd = "cat /run/secrets/mail-account-password";
      from = "Dmitry Shmakov <mail@wiyba.org>";
      aliases = "account@wiyba.org, admin@wiyba.org";
      default = "INBOX";
      copy-to = "Sent";
      cache-headers = true;
    };
  };
}
