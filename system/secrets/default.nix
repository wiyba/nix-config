[
  {
    sops = {
      defaultSopsFile = ./secrets.yaml;
      age.keyFile = "/etc/nixos/keys/sops-age.key";

      secrets.mihomo = {
        mode = "0400";
        path = "/etc/mihomo/config.yaml";
      };
      secrets.multi = {
        owner = "wiyba";
        mode = "0600";
        path = "/home/wiyba/.ssh/multi.key";
      };
    };
  }
]
