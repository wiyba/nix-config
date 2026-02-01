{ ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";

    containers.remnanode = {
      image = "remnawave/node:latest";
      extraOptions = [ "--network=host" ];

      environment = {
        NODE_PORT = "2323";
      };

      environmentFiles = [ "/run/secrets/remnanode.env" ];

      volumes = [
        "/var/log/remnanode:/var/log/remnanode"
      ];

      autoStart = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/log/remnanode 0755 root root -"
  ];

  services.logrotate = {
    enable = true;
    settings.remnanode = {
      files = "/var/log/remnanode/*.log";
      frequency = "daily";
      rotate = 5;
      size = "50M";
      compress = true;
      missingok = true;
      notifempty = true;
      copytruncate = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 2323 ];
}
