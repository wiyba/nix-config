{ config, ... }:

{
  age.secrets = {
    vless_ip = { file = ./ip.age; owner = "sing-box"; };
    vless_uuid = { file = ./uuid.age; owner = "sing-box"; };
    vless_sid = { file = ./sid.age; owner = "sing-box"; };
  };
}
