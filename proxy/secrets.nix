{ lib, ... }:
let
  users = [
    { name = "cvaze"; admin = false; }
    { name = "irs"; admin = false; }
    { name = "kika"; admin = false; }
    { name = "osman"; admin = false; }
    { name = "obguy"; admin = false; }
    { name = "stockholm"; admin = false; }
    { name = "wiyba"; admin = true; }
    { name = "home"; admin = true; }
    { name = "mamo"; admin = true; }
    { name = "papo"; admin = true; }
    { name = "nonplay"; admin = true; }
  ];

  hosts = [
    "almaty"
    "home"
    "stockholm"
  ];
in
{
  _module.args = {
    xrayUsers = users;
    xrayHosts = hosts;
  };

  sops.secrets = lib.mergeAttrsList (
    map
      (u: {
        "xray-uuid-${u.name}".key = "xray/${if u.admin then "admins" else "users"}/${u.name}";
      })
      users
    ++ map
      (h: {
        "xray-${h}-key-pub".key = "xray/${h}/key_pub";
        "xray-${h}-sid".key = "xray/${h}/sid";
      })
      hosts
  );
}
