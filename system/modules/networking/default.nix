{  lib, host, ... }:

{
  config = lib.mkMerge [
    # home
    (lib.mkIf (host == "home") {
      networking = {
        hostName = "home";
        domain = "wiyba.org";
        useDHCP = false;

        networkmanager = {
          enable = true;
          ensureProfiles.profiles = {
            enp0s20f0u1 = {
              connection = {
                id = "enp0s20f0u1";
                type = "ethernet";
                interface-name = "enp0s20f0u1";
              };
              ipv4 = {
                address1 = "192.168.1.1/24";
                method = "shared";
              };
            };

            enp4s0 = {
              connection = {
                id = "enp4s0";
                type = "ethernet";
                interface-name = "enp4s0";
              };
              ipv4 = {
                address1 = "192.168.10.2/24";
                dns = "1.1.1.1;8.8.8.8;";
                ignore-auto-dns = "true";
                method = "auto";
              };
            };
          };
        };

        nat = {
          enable = true;
          externalInterface = "enp4s0";
          internalInterfaces = [ "enp0s20f0u1" ];
        };

        firewall = {
          enable = false;
          allowedTCPPorts = [ 80 443 2222 ];
          allowedUDPPorts = [ 443 ];
          trustedInterfaces = [ "enp0s20f0u1" ];
        };
      };
    })

    # thinkpad
    (lib.mkIf (host == "thinkpad") {
      networking = {
        hostName = "thinkpad";
        modemmanager.enable = true;
        usePredictableInterfaceNames = lib.mkForce true;
      };
    })
  ];
}
