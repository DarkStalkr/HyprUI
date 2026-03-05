pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property string city: ""
    property string loc: ""
    property var cc: null
    property list<var> forecast: []
    property list<var> hourlyForecast: []

    readonly property string icon: cc ? Icons.getWeatherIcon(cc.weatherCode) : "cloud_alert"
    readonly property string description: cc?.weatherDesc ?? qsTr("No weather")
    readonly property string temp: cc ? cc.tempC + "°C" : "--°C"
    readonly property string feelsLike: cc ? cc.feelsLikeC + "°C" : "--°C"
    readonly property int humidity: cc?.humidity ?? 0
    readonly property real windSpeed: cc?.windSpeed ?? 0
    readonly property string sunrise: cc ? Qt.formatDateTime(new Date(cc.sunrise), "hh:mm A") : "--:--"
    readonly property string sunset: cc ? Qt.formatDateTime(new Date(cc.sunset), "hh:mm A") : "--:--"

    function reload(): void {
        // Simple autodetection via ipinfo for now
        Requests.get("https://ipinfo.io/json", function(text) {
            try {
                var response = JSON.parse(text);
                if (response.loc) {
                    loc = response.loc;
                    city = response.city ?? "";
                    fetchWeatherData();
                }
            } catch (e) {
                console.error("Weather reload error: " + e);
            }
        });
    }

    function fetchWeatherData(): void {
        if (!loc) return;
        var coords = loc.split(",");
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + coords[0] + "&longitude=" + coords[1] + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto";

        Requests.get(url, function(text) {
            try {
                var json = JSON.parse(text);
                if (!json.current || !json.daily) return;

                cc = {
                    weatherCode: json.current.weather_code,
                    weatherDesc: getWeatherCondition(json.current.weather_code),
                    tempC: Math.round(json.current.temperature_2m),
                    feelsLikeC: Math.round(json.current.apparent_temperature),
                    humidity: json.current.relative_humidity_2m,
                    windSpeed: json.current.wind_speed_10m,
                    isDay: json.current.is_day,
                    sunrise: json.daily.sunrise[0],
                    sunset: json.daily.sunset[0]
                };

                var forecastList = [];
                for (var i = 0; i < json.daily.time.length; i++) {
                    forecastList.push({
                        date: json.daily.time[i],
                        maxTempC: Math.round(json.daily.temperature_2m_max[i]),
                        minTempC: Math.round(json.daily.temperature_2m_min[i]),
                        weatherCode: json.daily.weather_code[i],
                        icon: Icons.getWeatherIcon(json.daily.weather_code[i])
                    });
                }
                forecast = forecastList;
            } catch (e) {
                console.error("Fetch weather data error: " + e);
            }
        });
    }

    function getWeatherCondition(code) {
        var conditions = {
            "0": "Clear", "1": "Mainly Clear", "2": "Partly Cloudy", "3": "Overcast",
            "45": "Fog", "48": "Depositing Rime Fog", "51": "Light Drizzle",
            "53": "Moderate Drizzle", "55": "Dense Drizzle", "61": "Slight Rain",
            "63": "Moderate Rain", "65": "Heavy Rain", "71": "Slight Snow",
            "73": "Moderate Snow", "75": "Heavy Snow", "95": "Thunderstorm"
        };
        return conditions[String(code)] || "Unknown";
    }

    Component.onCompleted: reload()

    Timer {
        interval: 1800000 // 30 mins
        running: true
        repeat: true
        onTriggered: reload()
    }
}
