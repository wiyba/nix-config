[{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/secrets/keys/sops-age.key";
    
    secrets.github = { mode = "0600"; path = "/etc/nixos/secrets/keys/github.key"; };
    secrets.vps = { mode = "0600"; path = "/etc/nixos/secrets/keys/vps.key"; };

    secrets.uuid = {};
    secrets.sid = {};
  };
}]
