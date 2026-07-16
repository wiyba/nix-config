{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /data/downloads 2775 qbittorrent media - -"
  ];

  systemd.services.qbittorrent.serviceConfig.UMask = "0002";

  services.qbittorrent = {
    enable = true;
    openFirewall = false;
    torrentingPort = 6881;
    webuiPort = 8080;
    group = "media";

    serverConfig = {
      BitTorrent.Session = {
        DefaultSavePath = "/data/downloads/";
        Port = 6881;
        Interface = "wan0";
        InterfaceName = "wan0";
        AsyncIOThreadsCount = 16;
        HashingThreadsCount = 2;
        SendBufferWatermark = 5000;
        SendBufferLowWatermark = 100;
        SendBufferWatermarkFactor = 50;
        MaxConnections = 500;
        MaxConnectionsPerTorrent = 100;
        MaxUploads = 20;
        MaxUploadsPerTorrent = 4;
        PeXEnabled = true;
        DHTEnabled = true;
        LSDEnabled = true;
        Encryption = 1;
        QueueingSystemEnabled = true;
        AddTorrentStopped = false;
      };

      Preferences = {
        General.Locale = "en";

        Connection.PortRangeMin = 6881;

        WebUI = {
          Address = "127.0.0.1";
          CSRFProtection = true;
          ClickjackingProtection = true;
          SecureCookie = true;
          HostHeaderValidation = false;
          ReverseProxySupportEnabled = true;
          TrustedReverseProxiesList = "127.0.0.1";
          AuthSubnetWhitelistEnabled = true;
          AuthSubnetWhitelist = "192.168.1.0/24";
          Password_PBKDF2 = ''"@ByteArray(coAM0H2x/PDgE497twz5zw==:OWcSJiGPxlC89pcntSbogTNQcfNQmyoZ/QzNE2JUNrgGX+obLev0D6BNTxoBsGP7fBJPH+mdt2L/dqNawKkqEw==)"'';
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 6881 ];
  networking.firewall.allowedTCPPorts = [ 6881 ];
}
