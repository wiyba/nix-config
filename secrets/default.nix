{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/secrets/keys/sops-age.key";
    
    secrets.github = { mode = "0600"; path = "/etc/nixos/secrets/keys/github.key"; };

    # smth for vless xray
    secrets.ip = {};
    secrets.uuid = {};
    secrets.sid = {};
  };
}
