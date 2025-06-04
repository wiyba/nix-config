{
  sops.age.keyFile = "/identity.txt";
  sops.defaultSopsFile = ../secrets/secrets.yaml;

  sops.secrets.vless_ip = {};
  sops.secrets.vless_uuid = {};
  sops.secrets.vless_sid = {};
}
