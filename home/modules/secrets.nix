{ ... }:

{
  age.secrets = {
    vless_ip = { file = ./ip.age; owner = "sing-box"; };
    vless_uuid = { file = ./uuid.age; owner = "sing-box"; };
    vless_sid = { file = ./sid.age; owner = "sing-box"; };
  };

  age.identyPaths = [ "/home/wiyba/.config/age/identity.txt" ];

  age.users.common = "age18m4k0w8cv57d95qwppnaryy7pjkdnhp74sft520zsu9df22lje3qz3j8pr";
}
