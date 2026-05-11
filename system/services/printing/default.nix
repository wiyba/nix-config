{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = false;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
