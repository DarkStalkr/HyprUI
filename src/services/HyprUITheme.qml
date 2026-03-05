pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string current: "mocha"
    
    readonly property var themes: ({
        "macos": {
            name: "macOS (Segmented)",
            background: "#181825", 
            surface: "#45475a",
            text: "#cdd6f4",
            error: "#f38ba8",
            rounding: 20,
            segmented: true,
            accents: {
                volume: "#cba6f7",
                brightness: "#f9e2af"
            }
        },
        "mocha": {
            name: "Mocha",
            background: "#1e1e2e",
            surface: "#313244",
            text: "#cdd6f4",
            error: "#f38ba8",
            rounding: 24,
            accents: {
                volume: "#cba6f7",
                brightness: "#f9e2af"
            }
        },
        "macchiato": {
            name: "Macchiato",
            background: "#24273a",
            surface: "#363a4f",
            text: "#cad3f5",
            error: "#ed8796",
            rounding: 24,
            accents: {
                volume: "#c6a0f6",
                brightness: "#eed49f"
            }
        },
        "frappe": {
            name: "Frappé",
            background: "#303446",
            surface: "#414559",
            text: "#c6d0f5",
            error: "#e78284",
            rounding: 24,
            accents: {
                volume: "#ca9ee6",
                brightness: "#e5c890"
            }
        },
        "latte": {
            name: "Latte",
            background: "#eff1f5",
            surface: "#ccd0da",
            text: "#4c4f69",
            error: "#d20f39",
            rounding: 24,
            accents: {
                volume: "#8839ef",
                brightness: "#df8e1d"
            }
        },
        "dracula": {
            name: "Dracula",
            background: "#282a36",
            surface: "#44475a",
            text: "#f8f8f2",
            error: "#ff5555",
            rounding: 24,
            accents: {
                volume: "#bd93f9",
                brightness: "#f1fa8c"
            }
        },
        "dracula-soft": {
            name: "Dracula Soft",
            background: "#282a36",
            surface: "#44475a",
            text: "#f8f8f2",
            error: "#ff8787",
            rounding: 24,
            accents: {
                volume: "#dac4f9",
                brightness: "#f5fabe"
            }
        },
        "tokyonight-day": {
            name: "Tokyo Night Day",
            background: "#e1e2e7",
            surface: "#d0d5e3",
            text: "#3760bf",
            error: "#c64343",
            rounding: 24,
            accents: {
                volume: "#2e7de9",
                brightness: "#8c6c3e"
            }
        },
        "tokyonight-moon": {
            name: "Tokyo Night Moon",
            background: "#222436",
            surface: "#1e2030",
            text: "#c8d3f5",
            error: "#c53b53",
            rounding: 24,
            accents: {
                volume: "#82aaff",
                brightness: "#ffc777"
            }
        },
        "tokyonight-night": {
            name: "Tokyo Night Night",
            background: "#1a1b26",
            surface: "#16161e",
            text: "#c0caf5",
            error: "#db4b4b",
            rounding: 24,
            accents: {
                volume: "#7aa2f7",
                brightness: "#e0af68"
            }
        },
        "tokyonight-storm": {
            name: "Tokyo Night Storm",
            background: "#24283b",
            surface: "#1f2335",
            text: "#c0caf5",
            error: "#db4b4b",
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
    }
}
