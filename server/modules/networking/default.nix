{ lib, host, ... }:

{
  config = lib.mkMerge [
    (lib.mkIf (host == "london") {
      networking = {
        hostName = "london";
        domain = "wiyba.org";

        dhcpcd.enable = false;
        nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        defaultGateway = "REDACTED";
        defaultGateway6 = "REDACTED";
        interfaces.ens3 = {
          ipv4.addresses = [
            {
              address = "REDACTED";
              prefixLength = 24;
            }
          ];
          ipv4.routes = [
            {
              address = "REDACTED";
              prefixLength = 32;
            }
          ];
          ipv6.addresses = [
            {
              address = "REDACTED";
              prefixLength = 64;
            }
          ];
          ipv6.routes = [
            {
              address = "REDACTED";
              prefixLength = 128;
            }
          ];
        };
        usePredictableInterfaceNames = lib.mkForce true;
      };
    })

    (lib.mkIf (host == "stockholm") {
      networking = {
        hostName = "stockholm";
        domain = "wiyba.org";

        dhcpcd.enable = false;
        nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        defaultGateway = "10.0.0.1";
        interfaces.ens3 = {
          ipv4 = {
            addresses = [
              {
                address = "87.121.105.20";
                prefixLength = 32;
              }
            ];
            routes = [
              {
                address = "10.0.0.1";
                prefixLength = 32;
              }
            ];
          };
        };
        usePredictableInterfaceNames = lib.mkForce true;
      };
    })
  ];
}
