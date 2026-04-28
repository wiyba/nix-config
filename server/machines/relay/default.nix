{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/mihomo
    ../../services/acme
    ../../services/xray
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
      timeoutStyle = "countdown";
      extraConfig = ''
        serial --unit=0 --speed=115200
        terminal_input serial console
        terminal_output serial console
      '';
    };
    kernelParams = [ "console=tty1" "console=ttyS0,115200n8" ];
  };

  zramSwap.enable = true;
  boot.tmp.cleanOnBoot = true;

  services.getty.autologinUser = "root";

  networking = {
    hostName = "relay";
    domain = "wiyba.org";
    usePredictableInterfaceNames = lib.mkForce false;
  };

  time.timeZone = "Europe/Moscow";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQmY892Awak26eH1iK0aEj7nILjGddlayY7e+fAwRV0 wiyba.org"
  ];

  system.stateVersion = "24.11";
}
