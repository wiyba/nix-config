{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/secrets/sops-age.key";
    
    # smth for vless xray
    secrets.ip = {};
    secrets.uuid = {};
    secrets.sid = {};
  };
}
