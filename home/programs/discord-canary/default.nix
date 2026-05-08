{ pkgs, lib, ... }:
let
  libopenh264 =
    pkgs.runCommand "libopenh264-2.5.1-linux64.7.so"
      {
        src = pkgs.fetchurl {
          url = "https://web.archive.org/web/20251005202247id_/http://ciscobinary.openh264.org/libopenh264-2.5.1-linux64.7.so.bz2";
          sha256 = "82e436db8606433e3f823c7fff3269c43b3ba3f12510a851ef7b156b80ad1b11";
        };
        nativeBuildInputs = [ pkgs.bzip2 ];
      }
      ''
        bunzip2 -c $src > $out
      '';
in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "discord-canary";
      paths = [ pkgs.discord-canary ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for b in discordcanary DiscordCanary; do
          wrapProgram $out/bin/$b \
            --add-flags "--enable-features=VaapiVideoDecoder,VaapiVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxGL" \
            --add-flags "--disable-features=UseChromeOSDirectVideoDecoder" \
            --add-flags "--ignore-gpu-blocklist --enable-zero-copy --ozone-platform-hint=wayland"
        done
      '';
    })
  ];

  home.activation.discordcanaryAddOpenH264 = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    TARGET="$HOME/.config/discordcanary/discord_asset_cache/openh264"
    DST="$TARGET/libopenh264-2.5.1-linux64.7.so"
    mkdir -p "$TARGET"
    if [ ! -f "$DST" ] || ! cmp -s ${libopenh264} "$DST"; then
      install -m644 ${libopenh264} "$DST"
    fi
  '';
}
