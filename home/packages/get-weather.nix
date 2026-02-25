{
  writeShellScriptBin,
  curl,
  jq,
  coreutils,
  ...
}:
[
  (writeShellScriptBin "get-weather" ''
    CACHE="/tmp/weather-cache.json"
    CACHE_MAX_AGE=600
    STALE_AGE=3600

    get_icon() {
        case $1 in
            01d|02d) icon="";;
            01n|02n) icon="";;
            03d|03n|04d|04n) icon="󰖐";;
            09d|09n|10d|10n) icon="󰖖";;
            11d|11n) icon="󰖓";;
            13d|13n) icon="󰖒";;
            50d|50n) icon="󰖑";;
            *) icon="?";;
        esac
        echo "$icon"
    }

    fallback() {
        ${jq}/bin/jq -nc \
          --arg text "󰖐  0.0°" \
          --arg tooltip "no connection" \
          --arg class "error" \
          '{"text": $text, "tooltip": $tooltip, "class": $class}'
    }

    now=$(${coreutils}/bin/date +%s)

    if [ -f "$CACHE" ]; then
        cache_time=$(${coreutils}/bin/stat -c %Y "$CACHE")
        age=$((now - cache_time))

        if [ "$age" -lt "$CACHE_MAX_AGE" ]; then
            ${coreutils}/bin/cat "$CACHE"
            exit 0
        fi
    fi

    KEY="e434b5435a979de6e155570590bee89b"
    LAT="55.778"
    LON="37.474"
    UNITS="metric"
    SYMBOL="°"
    API="https://api.openweathermap.org/data/2.5"

    weather=$(${curl}/bin/curl -sf --connect-timeout 5 "$API/weather?appid=$KEY&lat=$LAT&lon=$LON&units=$UNITS&lang=ru")

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

        result=$(${jq}/bin/jq -nc \
          --arg text "$text" \
          --arg tooltip "$tooltip" \
          --arg class "weather" \
          '{"text": $text, "tooltip": $tooltip, "class": $class}')

        echo "$result" > "$CACHE"
        echo "$result"
    else
        if [ -f "$CACHE" ]; then
            age=$((now - $(${coreutils}/bin/stat -c %Y "$CACHE")))
            if [ "$age" -lt "$STALE_AGE" ]; then
                ${coreutils}/bin/cat "$CACHE"
                exit 0
            fi
        fi
        fallback
    fi
  '')
]
