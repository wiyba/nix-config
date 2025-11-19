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
    mihomo-update = {
      description = "Update mihomo subscription";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "mihomo-update" ''
          SUB_URL=$(cat /etc/mihomo/sub)
          ${pkgs.curl}/bin/curl -H "User-Agent: mihomo" -o /etc/mihomo/config.yaml "$SUB_URL"
          systemctl restart mihomo.service
        '';
      };
    };
    flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo'';
    };
  };
}
