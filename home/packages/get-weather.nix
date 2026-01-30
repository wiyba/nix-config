{
  writeShellScriptBin,
  curl,
  jq,
  ...
}:
[(writeShellScriptBin "get-weather" ''
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
      weather_temp=$(echo "$weather" | ${jq}/bin/jq -r ".main.temp" | ${jq}/bin/jq -R 'tonumber | . * 10 | round / 10')
      weather_icon=$(echo "$weather" | ${jq}/bin/jq -r ".weather[0].icon")
      weather_main=$(echo "$weather" | ${jq}/bin/jq -r ".weather[0].main")
      weather_feels=$(echo "$weather" | ${jq}/bin/jq -r ".main.feels_like" | ${jq}/bin/jq -R 'tonumber | . * 10 | round / 10')
      weather_temp_min=$(echo "$weather" | ${jq}/bin/jq -r ".main.temp_min" | ${jq}/bin/jq -R 'tonumber | . * 10 | round / 10')
      weather_temp_max=$(echo "$weather" | ${jq}/bin/jq -r ".main.temp_max" | ${jq}/bin/jq -R 'tonumber | . * 10 | round / 10')
      weather_wind=$(echo "$weather" | ${jq}/bin/jq -r ".wind.speed" | ${jq}/bin/jq -R 'tonumber | . * 10 | round / 10')
      
      icon=$(get_icon "$weather_icon")
      text="$icon  $weather_temp$SYMBOL"
      tooltip=$'desc:\t'"$weather_main"$'\nfeels:\t'"$weather_feels$SYMBOL"$'\nmin:\t'"$weather_temp_min$SYMBOL"$'\nmax:\t'"$weather_temp_max$SYMBOL"$'\nspeed:\t'"$weather_wind"

      
      ${jq}/bin/jq -nc \
        --arg text "$text" \
        --arg tooltip "$tooltip" \
        --arg class "weather" \
        '{"text": $text, "tooltip": $tooltip, "class": $class}'
  else
      echo '{"text": "", "tooltip": "", "class": "error"}'
  fi
'')]
