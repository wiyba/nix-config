{ pkgs, ... }:

{
  home.packages = [ pkgs.albert ];
  xdg.configFile."albert/config".text = ''
    [General]
    additional_path_entires=
    showTray=false
    telemetry=false

    [applications]
    enabled=true
    global_handler_enabled=false
    terminal=footclient
    use_exec=false
    use_non_localized_name=false

    [clipboard]
    enabled=true
    persistent=true

    [mediaremote]
    enabled=false

    [path]
    enabled=true

    [pluginregistry]
    global_handler_enabled=false

    [system]
    command_lock=loginctl lock-session
    command_logout=logout
    command_poweroff=poweroff
    command_reboot=reboot
    enabled=true
    global_handler_enabled=false
    hibernate_enabled=false
    suspend_enabled=false

    [triggers]
    global_handler_enabled=false

    [widgetsboxmodel]
    alwaysOnTop=true
    clearOnHide=true
    clientShadow=true
    darkTheme=Default Dark
    displayScrollbar=false
    followCursor=true
    hideOnFocusLoss=true
    historySearch=true
    itemCount=5
    lightTheme=Default Dark
    quitOnClose=false
    showCentered=true
    systemShadow=true
  '';
}
