{ writeShellScriptBin, curl, jq, ... }:
writeShellScriptBin "get-weather" ''
  #!/bin/sh
  get_icon() {
      case $1 in
          # ясно, немного облачно днём
          01d|02d) icon="";;
          # ясно, немного облачно ночью
          01n|02n) icon="";;
          # облачно с прояснениями, пасмурно
          03d|03n|04d|04n) icon="󰖐";;
          # ливень, дождь
          09d|09n|10d|10n) icon="󰖖";;
          # гроза
          11d|11n) icon="󰖓";;
          # снег
          13d|13n) icon="󰖒";;
          # туман
          50d|50n) icon="󰖑";;
          # неизвестно
          *) icon="?";;
      esac
      echo "$icon"
  }
  KEY="e434b5435a979de6e155570590bee89b"
  LAT="55.778"
  LON="37.474"
  UNITS="metric"
  SYMBOL="°"
  API="https://api.openweathermap.org/data/2.5"
  weather=$(${curl}/bin/curl -sf "$API/weather?appid=$KEY&lat=$LAT&lon=$LON&units=$UNITS&lang=ru")
  if [ -n "$weather" ]; then
      weather_temp=$(echo "$weather" | ${jq}/bin/jq ".main.temp" | cut -d "." -f 1)
      weather_icon=$(echo "$weather" | ${jq}/bin/jq -r ".weather[0].icon")

      echo "$(get_icon "$weather_icon") $weather_temp$SYMBOL"
  fi
''
