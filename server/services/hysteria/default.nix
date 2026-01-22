{ pkgs, ... }:

let
  config = pkgs.writeText "hysteria.yaml" ''
    listen: :443

    # tls:
    #   cert: /var/lib/acme/status.wiyba.org/fullchain.pem
    #   key: /var/lib/acme/status.wiyba.org/key.pem
    acme:
      domains:
        - status.wiyba.org
      email: admin@wiyba.org

    # Remove server-side bandwidth limits - let client control it
    ignoreClientBandwidth: false

    resolver:
      type: udp
      tcp:
        addr: 78.110.174.195:53
        timeout: 4s
      udp:
        addr: 78.110.174.195:53
        timeout: 4s

    trafficStats:
      listen: 127.0.0.1:9999

    auth:
      type: password
      password:

    masquerade:
      type: proxy
      proxy:
        url: https://excalidraw.com/
        rewriteHost: true
  '';
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  systemd.services.hysteria-server = {
    description = "Hysteria Server";
    after = [
      "network.target"
      "acme-finished-status.wiyba.org.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server -c ${config}";
      Environment = "HYSTERIA_LOG_LEVEL=debug";
      Restart = "always";
      User = "root";
    };
  };
}
