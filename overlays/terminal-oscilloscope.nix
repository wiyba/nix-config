{ lib, stdenv, fetchFromGitHub, nim, makeWrapper, ffmpeg, wireplumber }:

stdenv.mkDerivation {
  pname = "terminal-oscilloscope";
  version = "unstable-2026-04-07";

  src = fetchFromGitHub {
    owner = "rolandnsharp";
    repo = "terminal-oscilloscope";
    rev = "f2a94befaa4b9de1c01a410f132e08032b447844";
    hash = "sha256-L1/1Hg7ig286KbNuo9ED5mJxpUIVBFdH5KHnVdBm390=";
  };

  nativeBuildInputs = [ nim makeWrapper ];

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    nim c -d:release --threads:on --nimcache:$TMPDIR/nimcache -o:osc_braille src/osc_braille.nim
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 osc_braille $out/bin/.osc_braille-unwrapped
    makeWrapper $out/bin/.osc_braille-unwrapped $out/bin/osc_braille \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ ffmpeg ]} \
      --prefix PATH : ${lib.makeBinPath [ wireplumber ]}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Terminal oscilloscope with CRT phosphor physics";
    homepage = "https://github.com/rolandnsharp/terminal-oscilloscope";
    license = licenses.mit;
    mainProgram = "osc_braille";
    platforms = platforms.linux;
  };
}
