{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/etc/nixos/keys/sops-age.key";

    secrets = {
      github = {
        mode = "0600";
        path = "/home/wiyba/.ssh/github.key";
      };
      vps = {
        mode = "0600";
        path = "/home/wiyba/.ssh/vps.key";
      };
      multi = {
        mode = "0600";
        path = "/home/wiyba/.ssh/multi.key";
      };
    };
  };
}
