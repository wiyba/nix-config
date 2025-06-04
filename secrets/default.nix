[
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "./sops-age.key";
    
    # smth for vless xray
    secrets.ip = {};
    secrets.uuid = {};
    secrets.sid = {};
  };
}
]
