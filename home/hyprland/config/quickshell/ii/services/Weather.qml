pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.common

Singleton {
    id: root

    // Настройка: фиксированные координаты
    readonly property real fixedLat: 55.778
    readonly property real fixedLon: 37.474
    readonly property string cityLabel: "Moscow"

    // Интервалы и опции
    readonly property int fetchInterval: Config.options.bar.weather.fetchInterval * 60 * 1000
    readonly property bool useUSCS: Config.options.bar.weather.useUSCS

    // Данные погоды
    property var data: ({
        uv: 0,
        humidity: 0,
        sunrise: 0,
        sunset: 0,
        windDir: 0,
        wCode: 0,
        city: 0,
        wind: 0,
        precip: 0,
        visib: 0,
        press: 0,
        temp: 0,
        tempFeelsLike: 0
    })

    // Конвертация времени из AM/PM в 24-часовой формат
    function to24h(t) {
        if (!t || typeof t !== "string") return "00:00";
        if (/^\d{1,2}:\d{2}$/.test(t) && !/[AP]M/i.test(t)) return t;

        const m = t.match(/^\s*(\d{1,2}):(\d{2})\s*(AM|PM)\s*$/i);
        if (!m) return t;

        let h = parseInt(m[1], 10);
        const min = m[2];
        const ampm = m[3].toUpperCase();

        if (ampm === "AM") {
            if (h === 12) h = 0;
        } else {
            if (h !== 12) h += 12;
        }

        const hh = String(h).padStart(2, "0");
        return `${hh}:${min}`;
    }


    // Обработка полученных данных о погоде
    function refineData(data) {
        let temp = {};
        temp.uv = data?.current?.uvIndex || 0;
        temp.humidity = (data?.current?.humidity || 0) + "%";
        temp.sunrise = to24h(data?.astronomy?.sunrise) || "00:00";
        temp.sunset = to24h(data?.astronomy?.sunset) || "00:00";
        temp.windDir = data?.current?.winddir16Point || "N";
        temp.wCode = data?.current?.weatherCode || "113";
        temp.city = root.cityLabel || data?.location?.areaName?.[0]?.value || "City";
        temp.temp = "";
        temp.tempFeelsLike = "";

        if (root.useUSCS) {
            temp.wind = (data?.current?.windspeedMiles || 0) + " mph";
            temp.precip = (data?.current?.precipInches || 0) + " in";
            temp.visib = (data?.current?.visibilityMiles || 0) + " m";
            temp.press = (data?.current?.pressureInches || 0) + " psi";
            temp.temp += (data?.current?.temp_F || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeF || 0);
            temp.temp += "°F";
            temp.tempFeelsLike += "°F";
        } else {
            temp.wind = (data?.current?.windspeedKmph || 0) + " km/h";
            temp.precip = (data?.current?.precipMM || 0) + " mm";
            temp.visib = (data?.current?.visibility || 0) + " km";
            temp.press = (data?.current?.pressure || 0) + " hPa";
            temp.temp += (data?.current?.temp_C || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeC || 0);
            temp.temp += "°C";
            temp.tempFeelsLike += "°C";
        }

        root.data = temp;
    }

    // Запрос данных о погоде с wttr.in
    function getData() {
        const cmd = `curl -s wttr.in/${root.fixedLat},${root.fixedLon}?format=j1 | jq '{current: .current_condition[0], location: .nearest_area[0], astronomy: .weather[0].astronomy[0]}'`;
        fetcher.exec({ command: ["bash", "-c", cmd] });
    }

    Component.onCompleted: {
        root.getData();
    }

    // Процесс для выполнения curl запроса
    Process {
        id: fetcher
        command: ["bash", "-c", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) return;
                try {
                    const parsedData = JSON.parse(text);
                    root.refineData(parsedData);
                } catch (e) {
                    console.error(`[WeatherService] ${e.message}`);
                }
            }
        }
    }

    // Таймер для периодического обновления данных
    Timer {
        running: true
        repeat: true
        interval: root.fetchInterval
        triggeredOnStart: true
        onTriggered: root.getData()
    }
}

