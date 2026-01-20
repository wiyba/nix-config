{ pkgs, ... }:

{
  systemd.services = {
    greetd = {
      serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
    };
    flatpak-repo = {
      wantedBy = [ "multi-user.target" ]; # change to network online target
      path = [ pkgs.flatpak ];
      script = ''flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo'';
    };
  };
}
