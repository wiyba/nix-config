{ pkgs, config, ... }:
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
      "sops-nix.service"
      "acme-${config.networking.fqdn}.service"
    ];
    wants = [ "acme-finished-${config.networking.fqdn}.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hysteria}/bin/hysteria server";
      Environment = "HYSTERIA_LOG_LEVEL=error";
      Restart = "always";
      User = "root";
    };
  };
}
