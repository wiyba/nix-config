{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../services/mihomo
    ../../services/acme
    ../../services/xray
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      grub = {
        enable = true;
        device = "/dev/sda";
        timeoutStyle = "countdown";
        extraConfig = ''
          serial --unit=0 --speed=115200
          terminal_input serial console
          terminal_output serial console
        '';
      };
    };
    kernelParams = [ "console=tty1" "console=ttyS0,115200n8" ];
  };

  systemd.network.links."10-wan0" = {
    matchConfig.MACAddress = "02:00:0e:3e:cf:1c";
    linkConfig.Name = "wan0";
  };

  networking = {
    hostName = "almaty";
    useNetworkd = true;
    useDHCP = true;
    enableIPv6 = true;
    dhcpcd.extraConfig = "nooption domain_name_servers";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
      "77.88.8.8"
    ];
  };

  services.qemuGuest.enable = true;

  services.cloud-init.enable = true;

  environment.etc."cloud/cloud.cfg.d/99-datasource.cfg".text = ''
    datasource_list: [ ConfigDrive, NoCloud, None ]
    datasource:
      ConfigDrive: {}
      NoCloud: {}
  '';

  services.zabbixAgent = {
    enable = true;
    server = "92.53.116.12,92.53.116.111,92.53.116.119";
    settings = {
      StartAgents = 3;
      ListenPort = 10050;
      DebugLevel = 3;
      Timeout = 30;
      DenyKey = "system.run[*]";
      UserParameter = "timeweb_config_version,echo 127";
    };
  };

  environment.systemPackages = with pkgs; [
    bash
    curl
    wget
    vim
    htop
    git
    python3
  ];

  time.timeZone = "Europe/Almaty";
}
