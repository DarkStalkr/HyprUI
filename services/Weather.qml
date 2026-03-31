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
    property int _requestGen: 0

    readonly property string icon: cc ? Icons.getWeatherIcon(cc.weatherCode) : "cloud_alert"
    readonly property string description: cc?.weatherDesc ?? qsTr("No weather")
    readonly property string temp: cc ? cc.tempC + "°C" : "--°C"
    readonly property string feelsLike: cc ? cc.feelsLikeC + "°C" : "--°C"
    readonly property int humidity: cc?.humidity ?? 0
    readonly property real windSpeed: cc?.windSpeed ?? 0
    readonly property string sunrise: cc ? Qt.formatDateTime(new Date(cc.sunrise), "hh:mm A") : "--:--"
    readonly property string sunset: cc ? Qt.formatDateTime(new Date(cc.sunset), "hh:mm A") : "--:--"

    function reload(): void {
        console.log("Weather: Reloading data...");
        const gen = ++root._requestGen;
        Requests.get("https://ipinfo.io/json", function(text) {
            if (gen !== root._requestGen) return;
            try {
                var response = JSON.parse(text);
                console.log("Weather: ipinfo.io response:", JSON.stringify(response, null, 2));
                if (response.loc) {
                    loc = response.loc;
                    city = response.city ?? "";
                    fetchWeatherData(gen);
                } else {
                    console.error("Weather: ipinfo.io did not return location data.");
                }
            } catch (e) {
                console.error("Weather reload error (ipinfo.io): " + e + "\\nResponse text: " + text);
            }
        }, function(errorText) {
            console.error("Weather: ipinfo.io request failed: " + errorText);
        });
    }

    function fetchWeatherData(gen): void {
        if (!loc) {
            console.warn("Weather: No location (loc) available to fetch weather data.");
            return;
        }
        var coords = loc.split(",");
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + coords[0] + "&longitude=" + coords[1] + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto";
        console.log("Weather: Fetching weather data from:", url);

        Requests.get(url, function(text) {
            if (gen !== root._requestGen) return;
            try {
                var json = JSON.parse(text);
                console.log("Weather: open-meteo.com response:", JSON.stringify(json, null, 2));
                if (!json.current || !json.daily) {
                    console.error("Weather: open-meteo.com did not return current or daily data.");
                    return;
                }

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
                console.error("Fetch weather data error (open-meteo.com): " + e + "\\nResponse text: " + text);
            }
        }, function(errorText) {
            console.error("Weather: open-meteo.com request failed: " + errorText);
        });
    }

    function getWeatherCondition(code) {
        var conditions = {
            "0": "Clear sky", "1": "Mainly clear", "2": "Partly cloudy", "3": "Overcast",
            "45": "Fog", "48": "Depositing rime fog", "51": "Light drizzle",
            "53": "Moderate drizzle", "55": "Dense drizzle", "56": "Light freezing drizzle",
            "57": "Dense freezing drizzle", "61": "Slight rain", "63": "Moderate rain",
            "65": "Heavy rain", "66": "Light freezing rain", "67": "Heavy freezing rain",
            "71": "Slight snow fall", "73": "Moderate snow fall", "75": "Heavy snow fall",
            "77": "Snow grains", "80": "Slight rain showers", "81": "Moderate rain showers",
            "82": "Violent rain showers", "85": "Slight snow showers", "86": "Heavy snow showers",
            "95": "Thunderstorm", "96": "Thunderstorm with slight hail", "99": "Thunderstorm with heavy hail"
        };
        var condition = conditions[String(code)];
        if (condition === undefined) {
            console.warn("Weather: Unknown weather code encountered: " + code);
            return "Unknown";
        }
        return condition;
    }

    Component.onCompleted: reload()

    Timer {
        interval: 1800000 // 30 mins
        running: true
        repeat: true
        onTriggered: reload()
    }
}
