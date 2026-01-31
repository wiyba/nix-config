{ lib, pkgs, ... }:

let
easyeffectsrc = pkgs.writeText "easyeffectsrc" ''
  [StreamInputs]
  inputDevice=
  visiblePage=pluginsPage

  [StreamOutputs]
  outputDevice=
  plugins=equalizer#0
  visiblePage=pluginsPage
  visiblePlugin=equalizer#0

  [Window]
  height=668
  showTrayIcon=false
  width=1251 
'';
equalizerrc = pkgs.writeText "equalizerrc" ''
  [soe][Equalizer#0]
  inputGain=-5
  numBands=10

  [soe][Equalizer#0#left]
  band0Frequency=31
  band0Gain=7.999999618530298
  band10Type=0
  band11Type=0
  band12Type=0
  band13Type=0
  band14Type=0
  band15Type=0
  band16Type=0
  band17Type=0
  band18Type=0
  band19Type=0
  band1Frequency=62
  band1Gain=7.000000133514423
  band20Type=0
  band21Type=0
  band22Type=0
  band23Type=0
  band24Type=0
  band25Type=0
  band26Type=0
  band27Type=0
  band28Type=0
  band29Type=0
  band2Frequency=125
  band2Gain=6.0000001716613784
  band30Type=0
  band31Type=0
  band3Frequency=250
  band3Gain=8.940696759329736e-10
  band4Frequency=500
  band4Gain=2
  band5Frequency=1000
  band5Gain=1
  band6Frequency=2000
  band7Frequency=4000
  band7Gain=4
  band8Frequency=8000
  band8Gain=4.500000000000011
  band9Frequency=16000
  band9Gain=5

  [soe][Equalizer#0#right]
  band0Frequency=31
  band0Gain=7.999999618530298
  band10Type=0
  band11Type=0
  band12Type=0
  band13Type=0
  band14Type=0
  band15Type=0
  band16Type=0
  band17Type=0
  band18Type=0
  band19Type=0
  band1Frequency=62
  band1Gain=7.000000133514423
  band20Type=0
  band21Type=0
  band22Type=0
  band23Type=0
  band24Type=0
  band25Type=0
  band26Type=0
  band27Type=0
  band28Type=0
  band29Type=0
  band2Frequency=125
  band2Gain=6.0000001716613784
  band30Type=0
  band31Type=0
  band3Frequency=250
  band3Gain=8.940696759329736e-10
  band4Frequency=500
  band4Gain=2
  band5Frequency=1000
  band5Gain=1
  band6Frequency=2000
  band7Frequency=4000
  band7Gain=4
  band8Frequency=8000
  band8Gain=4.500000000000011
  band9Frequency=16000
  band9Gain=5
'';
in {
  services.easyeffects.enable = true;
  home.activation.easyeffects = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/easyeffects/db"
    if [ ! -f "$HOME/.config/easyeffects/db/easyeffectsrc" ]; then
      cp ${easyeffectsrc} "$HOME/.config/easyeffects/db/easyeffectsrc"
      chmod u+w "$HOME/.config/easyeffects/db/easyeffectsrc"
    fi
    if [ ! -f "$HOME/.config/easyeffects/db/equalizerrc" ]; then
      cp ${equalizerrc} "$HOME/.config/easyeffects/db/equalizerrc"
      chmod u+w "$HOME/.config/easyeffects/db/equalizerrc"
    fi
  '';
}
