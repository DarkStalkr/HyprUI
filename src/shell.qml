//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import "modules"
import "services"
import "config" // Changed from "src/config"
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
        onPressed: {
            console.log("GlobalShortcut: cycle_theme pressed");
            HyprUITheme.cycle();
        }
    }

    // HYPRUI LAUNCHER
    // bind = SUPER, M, global, hyprui:toggle_launcher
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_launcher" // Name matches hyprland.conf bind entry
        onPressed: {
            console.log("GlobalShortcut: toggle_launcher pressed");
            UI.toggleLauncher();
        }
    }

    // HYPRUI DASHBOARD
    // bind = SUPER, D, global, hyprui:toggle_dashboard
    GlobalShortcut {
        appid: "hyprui"
        name: "toggle_dashboard"
        onPressed: {
            console.log("GlobalShortcut: toggle_dashboard pressed");
            UI.toggleDashboard();
        }
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
                    id: topBarInstance
                    screen: modelData
                }
                
                SideBar {
                    screen: modelData
                }
            }
        }
    }
}
