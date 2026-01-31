{ pkgs, ... }:

{
  home.packages = [ pkgs.albert ];
  xdg.configFile."albert/config".text = ''
    [General]
    showTray=false
    telemetry=false

    [applications]
    enabled=true
    fuzzy=true

    [clipboard]
    enabled=true
    persistent=true

    [pluginregistry]
    global_handler_enabled=false

    [system]
    command_lock=loginctl lock-session
    command_logout=logout
    command_poweroff=poweroff
    command_reboot=reboot
    enabled=true
    hibernate_enabled=false
    logout_enabled=true
    suspend_enabled=false

    [triggers]
    fuzzy=true

    [urlhandler]
    enabled=true

    [websearch]
    enabled=true
    global_handler_enabled=false

    [widgetsboxmodel]
    alwaysOnTop=true
    clearOnHide=true
    clientShadow=true
    displayScrollbar=false
    followCursor=true
    hideOnFocusLoss=true
    historySearch=true
    itemCount=5
    quitOnClose=false
    showCentered=true
    systemShadow=true
  '';
  xdg.configFile."albert/websearch/engines.json".text = ''
    [
    ]  
  '';
}
