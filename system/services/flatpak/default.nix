{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    packages = [
      "com.discordapp.Discord"
      "org.vinegarhq.Sober"
      "org.vinegarhq.Vinegar"
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
