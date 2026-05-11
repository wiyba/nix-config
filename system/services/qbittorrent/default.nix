{ ... }:
{
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    torrentingPort = 6881;
    webuiPort = 8080;
    serverConfig.Preferences = {
      "WebUI\\Address" = "127.0.0.1";
      "WebUI\\HostHeaderValidation" = false;
      "WebUI\\CSRFProtection" = false;
      "Connection\\PortRangeMin" = 6881;
    };
  };

  networking.firewall.allowedUDPPorts = [ 6881 ];
}
