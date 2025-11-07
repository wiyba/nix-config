[
  {
    sops = {
      defaultSopsFile = ./secrets.yaml;
      age.keyFile = "/etc/nixos/home/base/secrets/keys/sops-age.key";
      
      secrets.github = { mode = "0600"; path = "/home/wiyba/.ssh/github.key"; };
      secrets.vps = { mode = "0600"; path = "/home/wiyba/.ssh/vps.key"; };
      secrets.multi = { mode = "0600"; path = "/home/wiyba/.ssh/multi.key"; };
    };
  }
]
