[
  {
    sops = {
      defaultSopsFile = ./secrets.yaml;
      age.keyFile = "/etc/nixos/keys/sops-age.key";
      
      secrets.sub = { mode = "0400"; path = "/etc/mihomo/sub"; };
    };
  }
]
