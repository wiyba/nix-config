{
  age.identityPaths = [ "/home/wiyba/.config/age/identity.txt" ];
  age.secrets = {
    vless_ip = { file = ../secrets/ip.age; };
    vless_uuid = { file = ../secrets/uuid.age; };
    vless_sid = { file = ../secrets/sid.age; };
  };
}
