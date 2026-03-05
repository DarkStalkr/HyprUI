//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import "src/modules"
import "src/services"
import "src/config"
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    // HYPRUI THEME SWAP
    // bind = SUPER_SHIFT, T, global, hyprui:cycle_theme
    GlobalShortcut {
        appid: "hyprui"
        name: "cycle_theme"
        onPressed: HyprUITheme.cycle()
    }

    // HYPRUI LAUNCHER
    // bind = SUPER, SPACE, global, hyprui:toggle_launcher
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_launcher"
        onPressed: UI.toggleLauncher()
    }

    // HYPRUI DASHBOARD
    // bind = SUPER, D, global, hyprui:toggle_dashboard
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_dashboard"
        onPressed: UI.toggleDashboard()
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            Item {
                required property ShellScreen modelData
                
                HyprOSD {
                    screen: modelData
                }
                
                MediaPanel {
                    screen: modelData
                }
                
                Dashboard {
                    screen: modelData
                }
                
                Launcher {
                    screen: modelData
                }

                TopBar {
                    screen: modelData
                }
                
                SideBar {
                    screen: modelData
                }
            }
        }
    }
}
