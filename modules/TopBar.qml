import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import "../services"
import "../components"

Scope {
    id: root
    required property ShellScreen screen

    // Detect if there's a fullscreen window on this monitor
    readonly property bool isFullscreen: {
        const monitor = Hypr.monitors.values.find(m => m.name === root.screen.name)
        return monitor && monitor.activeWorkspace ? monitor.activeWorkspace.hasFullscreen : false
    }

    function formatSeconds(s) {
        if (s <= 0) return "Calculating..."
        const h = Math.floor(s / 3600)
        const m = Math.floor((s % 3600) / 60)
        if (h > 0) return h + "h " + m + "m"
        return m + "m"
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: !root.isFullscreen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-topbar"
        // Derived from UI so the compositor always reserves exactly the right
        // amount of space: margin + panelThickness + margin.
        WlrLayershell.exclusiveZone: UI.exclusiveZone

        anchors {
            top: true
            left: true
            right: true
        }

        // The window is taller than the bar so popups / tooltips have room to
        // render below it without being clipped. This value is intentionally
        // NOT scaled with the preset — it is popup headroom, not bar height.
        implicitHeight: 300
        color: "transparent"

        // Input mask shrinks/grows with the reserved zone so hover targets
        // always align with the visible bar, no matter the active preset.
        mask: Region {
            item: barBackground
        }

        Rectangle {
            id: barBackground
            anchors.top:    parent.top
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.margins: UI.panelMargin

            // Animated so preset switches feel intentional rather than jarring.
            height: UI.panelThickness
            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            radius:  HyprUITheme.active.rounding
            color:   HyprUITheme.active.background
            opacity: 0.95

            border.color: Qt.rgba(HyprUITheme.primary.r, HyprUITheme.primary.g, HyprUITheme.primary.b, 0.4)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                // Inner margins scale proportionally with the bar so content
                // never feels cramped at small or wasteful at large.
                anchors.leftMargin:  UI.panelMargin * 2
                anchors.rightMargin: Math.round(UI.panelMargin * 2.67)
                spacing: Math.round(UI.panelThickness * 0.67)

                // ── Left: Workspaces ────────────────────────────────────────
                RowLayout {
                    spacing: Math.round(UI.panelMargin * 1.33)

                    Repeater {
                        model: Hypr.workspaces.values

                        Rectangle {
                            id: wsRect
                            implicitWidth:  UI.wsSize
                            implicitHeight: UI.wsSize
                            radius: 0
                            color: modelData.id === Hypr.activeWsId
                                   ? HyprUITheme.primary
                                   : HyprUITheme.active.surface

                            Text {
                                anchors.centerIn: parent
                                text:       modelData.id
                                color:      modelData.id === Hypr.activeWsId
                                            ? HyprUITheme.active.background
                                            : HyprUITheme.active.text
                                font.family:    "MesloLGS NF"
                                font.pixelSize: UI.fontSize.sm
                                font.bold:      true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hypr.dispatch("workspace " + modelData.id)
                            }
                        }
                    }
                }

                // ── Centre: Active window title ─────────────────────────────
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text:           Hypr.activeToplevel?.title || "Desktop"
                    color:          HyprUITheme.active.text
                    font.family:    "MesloLGS NF"
                    font.pixelSize: UI.fontSize.md
                    elide:          Text.ElideRight
                    font.bold:      true
                }

                // ── Right: Status icons ─────────────────────────────────────
                RowLayout {
                    spacing: Math.round(UI.panelThickness * 0.43)

                    // System Tray
                    RowLayout {
                        spacing: Math.round(UI.panelMargin * 1.33)

                        Repeater {
                            model: SystemTray.items.values
                            delegate: Item {
                                id: trayItemRoot
                                implicitWidth:  UI.iconSize
                                implicitHeight: UI.iconSize

                                Image {
                                    anchors.fill: parent
                                    source:       modelData.icon || ""
                                    fillMode:     Image.PreserveAspectFit
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    hoverEnabled: true
                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.LeftButton) {
                                            modelData.activate()
                                        } else {
                                            const p = trayItemRoot.mapToItem(win.contentItem, mouse.x, mouse.y)
                                            modelData.display(win, p.x, p.y)
                                        }
                                    }
                                    onEntered: trayTooltip.requestShow()
                                    onExited:  trayTooltip.requestHide()
                                }

                                Tooltip {
                                    id:          trayTooltip
                                    text:        modelData.title || modelData.id
                                    orientation: "bottom"
                                    parent:      win.contentItem
                                    target:      trayItemRoot
                                }
                            }
                        }
                    }

                    // Network
                    Text {
                        id:   networkText
                        text: Network.wifiEnabled ? (Network.active ? "󰖩" : "󰖩") : "󰖪"
                        color: Network.active ? HyprUITheme.primary : HyprUITheme.active.text
                        font.family:    "MesloLGS NF"
                        font.pixelSize: UI.fontSize.lg

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["kitty", "-e", "nmtui"])
                            hoverEnabled: true
                            onEntered: wifiTooltip.requestShow()
                            onExited:  wifiTooltip.requestHide()
                        }

                        Tooltip {
                            id:          wifiTooltip
                            text:        Network.active ? "Connected: " + Network.active.ssid : "Disconnected"
                            orientation: "bottom"
                            parent:      win.contentItem
                            target:      networkText
                        }
                    }

                    // Bluetooth
                    Text {
                        text:    "󰂯"
                        color:   Bluetooth.defaultAdapter?.enabled ? HyprUITheme.primary : HyprUITheme.active.text
                        opacity: 0.8
                        font.family:    "MesloLGS NF"
                        font.pixelSize: UI.fontSize.lg

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.LeftButton) {
                                    Quickshell.execDetached(["/home/sohighman/.config/hypr/scripts/bluetooth-control.sh", "toggle"])
                                } else {
                                    Quickshell.execDetached(["blueberry"])
                                }
                            }
                        }
                    }

                    // Audio
                    Text {
                        id:    audioText
                        text:  Audio.muted ? "󰝟" : "󰕾"
                        color: Audio.muted ? HyprUITheme.active.error : HyprUITheme.primary
                        font.family:    "MesloLGS NF"
                        font.pixelSize: UI.fontSize.lg

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["pavucontrol"])
                            hoverEnabled: true
                            onEntered: audioTooltip.requestShow()
                            onExited:  audioTooltip.requestHide()
                        }

                        Tooltip {
                            id:          audioTooltip
                            text:        "Volume: " + Math.round(Audio.volume * 100) + "%"
                            orientation: "bottom"
                            parent:      win.contentItem
                            target:      audioText
                        }
                    }

                    // Battery
                    Text {
                        id:      battText
                        visible: UPower.displayDevice.isLaptopBattery

                        readonly property bool isCharging:
                            UPower.displayDevice.state === UPowerDeviceState.Charging ||
                            UPower.displayDevice.state === UPowerDeviceState.FullyCharged
                        readonly property real percentage: UPower.displayDevice.percentage * 100

                        text: {
                            if (isCharging) return " " + Math.round(percentage) + "%"
                            const icons = ["", "", "", "", ""]
                            return icons[Math.min(Math.floor(percentage / 20), 4)] + " " + Math.round(percentage) + "%"
                        }
                        color: isCharging
                               ? HyprUITheme.active.green
                               : (percentage <= 15 ? HyprUITheme.active.error
                               : (percentage <= 30 ? HyprUITheme.secondary
                               : HyprUITheme.active.green))
                        font.family:    "MesloLGS NF"
                        font.pixelSize: UI.fontSize.md
                        font.bold:      true

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: battTooltip.requestShow()
                            onExited:  battTooltip.requestHide()
                        }

                        Tooltip {
                            id:          battTooltip
                            text:        (UPower.onBattery ? "Remaining: " : "Time to Full: ") +
                                         root.formatSeconds(UPower.onBattery
                                             ? UPower.displayDevice.timeToEmpty
                                             : UPower.displayDevice.timeToFull)
                            orientation: "bottom"
                            parent:      win.contentItem
                            target:      battText
                        }
                    }

                    // Night Light
                    Text {
                        text:  "󱩍"
                        color: HyprUITheme.active.text
                        font.family:    "MesloLGS NF"
                        font.pixelSize: UI.fontSize.lg

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["/home/sohighman/Documentos/Scripts/toggle_night_light.sh"])
                        }
                    }

                    // Clock
                    Text {
                        text:           Time.timeStr
                        color:          HyprUITheme.active.text
                        font.family:    "MesloLGS NF"
                        font.pixelSize: UI.fontSize.md
                        font.bold:      true
                    }

                    // Power / logout
                    Text {
                        text:  ""
                        color: HyprUITheme.active.error
                        font.family:    "MesloLGS NF"
                        font.pixelSize: UI.fontSize.lg

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["wlogout"])
                        }
                    }
                }
            }
        }
    }
}
