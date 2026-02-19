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
        defaultGateway = "45.154.197.1";
        defaultGateway6 = "2a12:ab46:5344::1";
        interfaces.ens3 = {
          ipv4.addresses = [
            {
              address = "45.154.197.120";
              prefixLength = 24;
            }
          ];
          ipv4.routes = [
            {
              address = "45.154.197.1";
              prefixLength = 32;
            }
          ];
          ipv6.addresses = [
            {
              address = "2a12:ab46:5344:96::a";
              prefixLength = 64;
            }
          ];
          ipv6.routes = [
            {
              address = "2a12:ab46:5344::1";
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
