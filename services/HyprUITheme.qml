pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string current: "mocha"
    
    readonly property var themes: ({
        "macos": {
            name: "macOS (Segmented)",
            background: "#DD181825",
            surface: "#BB45475a",
            text: "#cdd6f4",
            error: "#f38ba8",
            green: "#a6e3a1",
            rounding: 20,
            segmented: true,
            accents: {
                volume: "#cba6f7",
                brightness: "#f9e2af"
            }
        },
        "mocha": {
            name: "Mocha",
            background: "#DD1e1e2e",
            surface: "#BB313244",
            text: "#cdd6f4",
            error: "#f38ba8",
            green: "#a6e3a1",
            rounding: 24,
            accents: {
                volume: "#cba6f7",
                brightness: "#f9e2af"
            }
        },
        "macchiato": {
            name: "Macchiato",
            background: "#DD24273a",
            surface: "#BB363a4f",
            text: "#cad3f5",
            error: "#ed8796",
            green: "#a6e3a1",
            rounding: 24,
            accents: {
                volume: "#c6a0f6",
                brightness: "#eed49f"
            }
        },
        "frappe": {
            name: "Frappé",
            background: "#DD303446",
            surface: "#BB414559",
            text: "#c6d0f5",
            error: "#e78284",
            green: "#a6e3a1",
            rounding: 24,
            accents: {
                volume: "#ca9ee6",
                brightness: "#e5c890"
            }
        },
        "latte": {
            name: "Latte",
            background: "#DDeff1f5",
            surface: "#BBccd0da",
            text: "#4c4f69",
            error: "#d20f39",
            green: "#40a02b",
            rounding: 24,
            accents: {
                volume: "#8839ef",
                brightness: "#df8e1d"
            }
        },
        "dracula": {
            name: "Dracula",
            background: "#DD282a36",
            surface: "#BB44475a",
            text: "#f8f8f2",
            error: "#ff5555",
            green: "#50fa7b",
            rounding: 24,
            accents: {
                volume: "#bd93f9",
                brightness: "#f1fa8c"
            }
        },
        "dracula-soft": {
            name: "Dracula Soft",
            background: "#DD282a36",
            surface: "#BB44475a",
            text: "#f8f8f2",
            error: "#ff8787",
            green: "#50fa7b",
            rounding: 24,
            accents: {
                volume: "#dac4f9",
                brightness: "#f5fabe"
            }
        },
        "tokyonight-day": {
            name: "Tokyo Night Day",
            background: "#DDe1e2e7",
            surface: "#BBd0d5e3",
            text: "#3760bf",
            error: "#c64343",
            green: "#485e30",
            rounding: 24,
            accents: {
                volume: "#2e7de9",
                brightness: "#8c6c3e"
            }
        },
        "tokyonight-moon": {
            name: "Tokyo Night Moon",
            background: "#DD222436",
            surface: "#BB1e2030",
            text: "#c8d3f5",
            error: "#c53b53",
            green: "#c3e88d",
            rounding: 24,
            accents: {
                volume: "#82aaff",
                brightness: "#ffc777"
            }
        },
        "tokyonight-night": {
            name: "Tokyo Night Night",
            background: "#DD1a1b26",
            surface: "#BB16161e",
            text: "#c0caf5",
            error: "#db4b4b",
            green: "#9ece6a",
            rounding: 24,
            accents: {
                volume: "#7aa2f7",
                brightness: "#e0af68"
            }
        },
        "tokyonight-storm": {
            name: "Tokyo Night Storm",
            background: "#DD24283b",
            surface: "#BB1f2335",
            text: "#c0caf5",
            error: "#db4b4b",
            green: "#9ece6a",
            rounding: 24,
            accents: {
                volume: "#7aa2f7",
                brightness: "#e0af68"
            }
        }
    })

    readonly property var active: themes[current]
    
    // Convenience properties to avoid deep nesting
    readonly property color primary: active.accents.volume
    readonly property color secondary: active.accents.brightness
    
    readonly property var anim: ({
        fast: 150,
        normal: 300,
        curve: Easing.OutQuint
    })

    function cycle() {
        let keys = Object.keys(themes);
        current = keys[(keys.indexOf(current) + 1) % keys.length];
        console.log("HyprUITheme: Cycling theme to: " + current);
        
        // Trigger accessibility notification
        Notifications.send("Theme Changed", "HyprUI is now using: " + active.name);
    }
}
