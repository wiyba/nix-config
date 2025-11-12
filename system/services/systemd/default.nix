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
    modem-fix = {
      description = "Fix Lenovo Connect modem initialization";
      wantedBy = [ "post-resume.target" ];
      after = [ "ModemManager.service" "suspend.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "modem-fix" ''
          sleep 3
          ${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 2dee -p 4d54 -R || true
          sleep 2
          ${pkgs.systemd}/bin/systemctl restart ModemManager.service
          sleep 3
          ${pkgs.modemmanager}/bin/mmcli -S || true
          sleep 10
          
          for i in {1..60}; do
            if ${pkgs.modemmanager}/bin/mmcli -L | grep -q "MDM9207"; then
              echo "Modem detected successfully"
              exit 0
            fi
            sleep 1
          done
          
          echo "Modem detection timeout, but continuing..."
        '';
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