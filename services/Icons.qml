pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../config"

Singleton {
    id: root

    readonly property var weatherIcons: ({
            "0": "\uf185", // fa-sun (Clear sky)
            "1": "\uf185", // fa-sun (Mainly clear)
            "2": "\ue312", // wi-day-cloudy (Partly cloudy)
            "3": "\ue335", // wi-cloudy (Overcast)
            "45": "\ue320", // wi-fog (Fog)
            "48": "\ue320", // wi-fog (Depositing rime fog)
            "51": "\ue308", // wi-sprinkle (Light drizzle)
            "53": "\ue308", // wi-sprinkle (Moderate drizzle)
            "55": "\ue308", // wi-sprinkle (Dense drizzle)
            "56": "\uf2dc", // fa-snowflake (Light freezing drizzle)
            "57": "\uf2dc", // fa-snowflake (Dense freezing drizzle)
            "61": "\ue306", // wi-day-rain (Slight rain)
            "63": "\ue306", // wi-day-rain (Moderate rain)
            "65": "\ue317", // wi-rain (Heavy rain)
            "66": "\uf2dc", // fa-snowflake (Light freezing rain)
            "67": "\uf2dc", // fa-snowflake (Heavy freezing rain)
            "71": "\ue30a", // wi-snow (Slight snow fall)
            "73": "\ue30a", // wi-snow (Moderate snow fall)
            "75": "\uf2dc", // fa-snowflake (Heavy snow fall)
            "77": "\ue30a", // wi-snow (Snow grains)
            "80": "\ue316", // wi-showers (Slight rain showers)
            "81": "\ue316", // wi-showers (Moderate rain showers)
            "82": "\ue316", // wi-showers (Violent rain showers)
            "85": "\ue311", // wi-snow-wind (Slight snow showers)
            "86": "\ue311", // wi-snow-wind (Heavy snow showers)
            "95": "\ue30f", // wi-thunderstorm (Thunderstorm)
            "96": "\ue30f", // wi-thunderstorm (Thunderstorm with slight hail)
            "99": "\ue30f"  // wi-thunderstorm (Thunderstorm with heavy hail)
        })

    readonly property var categoryIcons: ({
            WebBrowser: "web",
            Printing: "print",
            Security: "security",
            Network: "chat",
            Archiving: "archive",
            Compression: "archive",
            Development: "code",
            IDE: "code",
            TextEditor: "edit_note",
            Audio: "music_note",
            Music: "music_note",
            Player: "music_note",
            Recorder: "mic",
            Game: "sports_esports",
            FileTools: "files",
            FileManager: "files",
            Filesystem: "files",
            FileTransfer: "files",
            Settings: "settings",
            DesktopSettings: "settings",
            HardwareSettings: "settings",
            TerminalEmulator: "terminal",
            ConsoleOnly: "terminal",
            Utility: "build",
            Monitor: "monitor_heart",
            Midi: "graphic_eq",
            Mixer: "graphic_eq",
            AudioVideoEditing: "video_settings",
            AudioVideo: "music_video",
            Video: "videocam",
            Building: "construction",
            Graphics: "photo_library",
            "2DGraphics": "photo_library",
            RasterGraphics: "photo_library",
            TV: "tv",
            System: "host",
            Office: "content_paste"
        })

    function getAppIcon(name: string, fallback: string): string {
        const icon = DesktopEntries.heuristicLookup(name)?.icon;
        if (fallback !== "undefined")
            return Quickshell.iconPath(icon, fallback);
        return Quickshell.iconPath(icon);
    }

    function getAppCategoryIcon(name: string, fallback: string): string {
        const categories = DesktopEntries.heuristicLookup(name)?.categories;

        if (categories)
            for (const [key, value] of Object.entries(categoryIcons))
                if (categories.includes(key))
                    return value;
        return fallback;
    }

    function getNetworkIcon(strength: int, isSecure = false): string {
        if (isSecure) {
            if (strength >= 80)
                return "network_wifi_locked";
            if (strength >= 60)
                return "network_wifi_3_bar_locked";
            if (strength >= 40)
                return "network_wifi_2_bar_locked";
            if (strength >= 20)
                return "network_wifi_1_bar_locked";
            return "signal_wifi_0_bar";
        } else {
            if (strength >= 80)
                return "network_wifi";
            if (strength >= 60)
                return "network_wifi_3_bar";
            if (strength >= 40)
                return "network_wifi_2_bar";
            if (strength >= 20)
                return "network_wifi_1_bar";
            return "signal_wifi_0_bar";
        }
    }

    function getBluetoothIcon(icon: string): string {
        if (icon.includes("headset") || icon.includes("headphones"))
            return "headphones";
        if (icon.includes("audio"))
            return "speaker";
        if (icon.includes("phone"))
            return "smartphone";
        if (icon.includes("mouse"))
            return "mouse";
        if (icon.includes("keyboard"))
            return "keyboard";
        return "bluetooth";
    }

    function getWeatherIcon(code: string): string {
        if (weatherIcons.hasOwnProperty(code))
            return weatherIcons[code];
        return "\uf059"; // fa-question-circle (Nerd Font fallback)
    }

    function getNotifIcon(summary: string, urgency: int): string {
        summary = summary.toLowerCase();
        if (summary.includes("reboot"))
            return "restart_alt";
        if (summary.includes("recording"))
            return "screen_record";
        if (summary.includes("battery"))
            return "power";
        if (summary.includes("screenshot"))
            return "screenshot_monitor";
        if (summary.includes("welcome"))
            return "waving_hand";
        if (summary.includes("time") || summary.includes("a break"))
            return "schedule";
        if (summary.includes("installed"))
            return "download";
        if (summary.includes("update"))
            return "update";
        if (summary.includes("unable to"))
            return "deployed_code_alert";
        if (summary.includes("profile"))
            return "person";
        if (summary.includes("file"))
            return "folder_copy";
        if (urgency === NotificationUrgency.Critical)
            return "release_alert";
        return "chat";
    }

    function getVolumeIcon(volume: real, isMuted: bool): string {
        if (isMuted)
            return "no_sound";
        if (volume >= 0.5)
            return "volume_up";
        if (volume > 0)
            return "volume_down";
        return "volume_mute";
    }

    function getMicVolumeIcon(volume: real, isMuted: bool): string {
        if (!isMuted && volume > 0)
            return "mic";
        return "mic_off";
    }

    function getSpecialWsIcon(name: string): string {
        name = name.toLowerCase().slice("special:".length);

        for (const iconConfig of Config.bar.workspaces.specialWorkspaceIcons) {
            if (iconConfig.name === name) {
                return iconConfig.icon;
            }
        }

        if (name === "special")
            return "star";
        if (name === "communication")
            return "forum";
        if (name === "music")
            return "music_cast";
        if (name === "todo")
            return "checklist";
        if (name === "sysmon")
            return "monitor_heart";
        return name[0].toUpperCase();
    }

    function getOsdIcon(mode: string, value: real, isMuted: bool): string {
        if (mode === "volume") {
            if (isMuted || value === 0) return "󰝟"; // Muted
            if (value < 0.33) return "󰕿"; // Low
            if (value < 0.66) return "󰖀"; // Mid
            return "󰕾"; // High
        } else {
            // Brightness
            if (value < 0.33) return "󰃞"; // Low
            if (value < 0.66) return "󰃟"; // Mid
            return "󰃠"; // High
        }
    }

    function getTrayIcon(id: string, icon: string): string {
        for (const sub of Config.bar.tray.iconSubs)
            if (sub.id === id)
                return sub.image ? Qt.resolvedUrl(sub.image) : Quickshell.iconPath(sub.icon);

        if (icon.includes("?path=")) {
            const [name, path] = icon.split("?path=");
            icon = Qt.resolvedUrl(`${path}/${name.slice(name.lastIndexOf("/") + 1)}`);
        }
        return icon;
    }
}
