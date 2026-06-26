{ config
, lib
, pkgs
, ...
}:
let
  liveFlag = "/run/mediamtx/live";
  presencePort = 8890;
  # TotallyNotHenry was here btw sooooooo coooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooool

  hlsJs = pkgs.fetchurl {
    url = "https://cdn.jsdelivr.net/npm/hls.js@1.6.16/dist/hls.min.js";
    hash = "sha256-RC9ZnDTxA8M1WzdaI73/VgWS1xF9CajIRyQuo94tQOA=";
  };

  webroot = pkgs.runCommand "stream-www" { } ''
    mkdir -p $out
    cp ${./player.html} $out/player.html
    cp ${hlsJs}         $out/hls.min.js
  '';
in
{
  sops.secrets.mediamtx-pass = { };

  sops.templates."mediamtx.yaml" = {
    owner = "root";
    mode = "0444";
    path = "/run/secrets/mediamtx.yaml";
    restartUnits = [ "mediamtx.service" ];
    content = ''
      logLevel: warn
      api: no
      metrics: no
      pprof: no
      playback: no
      rtsp: no
      srt: no
      rtmp: no

      webrtc: yes
      webrtcAddress: 127.0.0.1:8889
      webrtcEncryption: no
      webrtcLocalUDPAddress: :8189
      webrtcLocalTCPAddress: :8189
      webrtcIPsFromInterfaces: yes
      webrtcIPsFromInterfacesList: [ wan0, lan0 ]

      hls: yes
      hlsAddress: 127.0.0.1:8888
      hlsVariant: fmp4

      authInternalUsers:
        - user: any
          pass:
          ips: []
          permissions:
            - action: read
        - user: streamer
          pass: ${config.sops.placeholder.mediamtx-pass}
          ips: []
          permissions:
            - action: publish
              path: live

      paths:
        live:
          runOnReady: ${pkgs.coreutils}/bin/touch ${liveFlag}
          runOnNotReady: ${pkgs.coreutils}/bin/rm -f ${liveFlag}
    '';
  };

  services.mediamtx.enable = true;

  systemd.services.mediamtx = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
    serviceConfig = {
      LoadCredential = [ "mediamtx.yaml:/run/secrets/mediamtx.yaml" ];
      ExecStart = lib.mkForce "${config.services.mediamtx.package}/bin/mediamtx %d/mediamtx.yaml";
      RuntimeDirectory = "mediamtx";
      RuntimeDirectoryMode = "0755";
    };
  };

  systemd.services.stream-presence = {
    description = "stream presence (SSE)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      HOST = "127.0.0.1";
      PORT = toString presencePort;
    };
    serviceConfig = {
      ExecStart = "${pkgs.nodejs}/bin/node ${./presence.mjs}";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8189 ];
  networking.firewall.allowedUDPPorts = [ 8189 ];

  services.nginx.virtualHosts."stream.wiyba.org" = {
    forceSSL = true;
    useACMEHost = "wiyba.org";
    root = webroot;
    locations = {
      "= /".extraConfig = ''
        if (-f ${liveFlag}) { rewrite ^ /player.html last; }
        return 418;
      '';
      "/".extraConfig = ''
        if (!-f ${liveFlag}) { return 418; }
        try_files $uri =404;
      '';
      "= /live/".extraConfig = "return 418;";
      "/live/whip" = {
        proxyPass = "http://127.0.0.1:8889/live/whip";
        extraConfig = ''
          proxy_intercept_errors on;
          error_page 400 401 403 404 405 500 502 503 504 =418 @mask;
          proxy_buffering off;
        '';
      };
      "/live/whep" = {
        proxyPass = "http://127.0.0.1:8889/live/whep";
        extraConfig = ''
          if (!-f ${liveFlag}) { return 418; }
          proxy_buffering off;
        '';
      };
      "/live/" = {
        proxyPass = "http://127.0.0.1:8888/live/";
        extraConfig = ''
          if (!-f ${liveFlag}) { return 418; }
          proxy_buffering off;
          add_header Cache-Control no-cache always;
        '';
      };
      "/presence" = {
        proxyPass = "http://127.0.0.1:${toString presencePort}";
        extraConfig = ''
          if (!-f ${liveFlag}) { return 418; }
          proxy_http_version 1.1;
          proxy_buffering off;
          proxy_read_timeout 1h;
        '';
      };
      "@mask".extraConfig = "return 418;";
    };
  };
}
