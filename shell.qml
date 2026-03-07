//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import "modules"
import "services"
import "config"
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    // HYPRUI THEME SWAP
    GlobalShortcut {
        appid: "hyprui"
        name: "cycle_theme"
        onPressed: HyprUITheme.cycle()
    }

    // HYPRUI LAUNCHER
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_launcher"
        onPressed: UI.toggleLauncher()
    }

    // HYPRUI DASHBOARD
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_dashboard"
        onPressed: UI.toggleDashboard()
    }

    // HYPRUI CONTROL CENTER
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_control_center"
        onPressed: UI.toggleControlCenter()
    }

    // HYPRUI VOLUME
    GlobalShortcut {
        appid: "hyprui"
        name: "increase_volume"
        onPressed: Audio.increaseVolume()
    }
    GlobalShortcut {
        appid: "hyprui"
        name: "decrease_volume"
        onPressed: Audio.decreaseVolume()
    }
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_mute"
        onPressed: Audio.toggleMute()
    }

    // HYPRUI BRIGHTNESS
    GlobalShortcut {
        appid: "hyprui"
        name: "increase_brightness"
        onPressed: Brightness.increase()
    }
    GlobalShortcut {
        appid: "hyprui"
        name: "decrease_brightness"
        onPressed: Brightness.decrease()
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            Item {
                required property ShellScreen modelData
                
                HyprOSD { screen: modelData }
                MediaPanel { screen: modelData }
                Dashboard { screen: modelData }
                Launcher { screen: modelData }
                TopBar { id: topBarInstance; screen: modelData }
                SideBar { screen: modelData }
                ControlCenter { screen: modelData }
                NotificationPopups { screen: modelData }
            }
        }
    }
}
