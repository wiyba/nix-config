{ pkgs, ... }:

{
  systemd.services = {
    ModemManager = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart     = "always";
        RestartSec  = "2s";
      };
    };
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
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "mihomo-update" ''
          SUB_URL=$(cat /etc/mihomo/sub)
          ${pkgs.curl}/bin/curl -H "User-Agent: mihomo" -o /etc/mihomo/config.yaml "$SUB_URL"
          systemctl restart mihomo.service
        '';
      };
    };
  };
}