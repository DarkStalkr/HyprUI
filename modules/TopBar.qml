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
        const monitor = Hypr.monitors.values.find(m => m.name === root.screen.name);
        return monitor && monitor.activeWorkspace ? monitor.activeWorkspace.hasFullscreen : false;
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
        // Hide automatically in fullscreen
        visible: !root.isFullscreen
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-topbar"
        WlrLayershell.exclusiveZone: 57
        
        anchors {
            top: true
            left: true
            right: true
        }
        
        implicitHeight: 300
        color: "transparent"
        
        mask: Region {
            width: win.width
            height: 69
        }

        Rectangle {
            id: barBackground
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            height: 45
            
            radius: HyprUITheme.active.rounding
            color: HyprUITheme.active.background
            opacity: 0.95
            
            border.color: Qt.rgba(HyprUITheme.primary.r, HyprUITheme.primary.g, HyprUITheme.primary.b, 0.4)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18 
                anchors.rightMargin: 25 
                spacing: 30 

                // Left: Workspaces
                RowLayout {
                    spacing: 12 
                    Repeater {
                        model: Hypr.workspaces.values
                        
                        Rectangle {
                            id: wsRect
                            implicitWidth: 26
                            implicitHeight: 26
                            // Reverted radius to 0 for squares
                            radius: 0
                            color: modelData.id === Hypr.activeWsId ? HyprUITheme.primary : HyprUITheme.active.surface
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.id
                                color: modelData.id === Hypr.activeWsId ? HyprUITheme.active.background : HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 12
                                font.bold: true
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hypr.dispatch("workspace " + modelData.id)
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Hypr.activeToplevel?.title || "Desktop"
                    color: HyprUITheme.active.text
                    font.family: "MesloLGS NF"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    font.bold: true
                }

                // Right: Status Icons
                RowLayout {
                    spacing: 20 
                    
                    // System Tray
                    RowLayout {
                        spacing: 12 
                        Repeater {
                            model: SystemTray.items.values
                            delegate: Item {
                                id: trayItemRoot
                                implicitWidth: 24
                                implicitHeight: 24
                                
                                Image {
                                    anchors.fill: parent
                                    source: modelData.icon || ""
                                    fillMode: Image.PreserveAspectFit
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    hoverEnabled: true
                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.LeftButton) {
                                            modelData.activate();
                                        } else {
                                            var windowPos = trayItemRoot.mapToItem(win.contentItem, mouse.x, mouse.y);
                                            modelData.display(win, windowPos.x, windowPos.y);
                                        }
                                    }
                                    onEntered: trayTooltip.requestShow()
                                    onExited: trayTooltip.requestHide()
                                }
                                
                                Tooltip {
                                    id: trayTooltip
                                    text: modelData.title || modelData.id
                                    orientation: "bottom"
                                    parent: win.contentItem
                                    target: trayItemRoot
                                }
                            }
                        }
                    }

                    // Network
                    Text {
                        id: networkText
                        text: Network.wifiEnabled ? (Network.active ? "󰖩" : "󰖩") : "󰖪"
                        color: Network.active ? HyprUITheme.primary : HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        font.pixelSize: 18 
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["kitty", "-e", "nmtui"])
                            hoverEnabled: true
                            onEntered: wifiTooltip.requestShow()
                            onExited: wifiTooltip.requestHide()
                        }
                        
                        Tooltip {
                            id: wifiTooltip
                            text: Network.active ? "Connected: " + Network.active.ssid : "Disconnected"
                            orientation: "bottom"
                            parent: win.contentItem
                            target: networkText
                        }
                    }
                    
                    // Bluetooth
                    Text {
                        text: "󰂯"
                        color: Bluetooth.defaultAdapter?.enabled ? HyprUITheme.primary : HyprUITheme.active.text
                        opacity: 0.8
                        font.family: "MesloLGS NF"
                        font.pixelSize: 18 
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.LeftButton) {
                                    Quickshell.execDetached(["/home/sohighman/.config/hypr/scripts/bluetooth-control.sh", "toggle"]);
                                } else {
                                    Quickshell.execDetached(["blueberry"]);
                                }
                            }
                        }
                    }
                    
                    // Audio
                    Text {
                        id: audioText
                        text: Audio.muted ? "󰝟" : "󰕾"
                        color: Audio.muted ? HyprUITheme.active.error : HyprUITheme.primary
                        font.family: "MesloLGS NF"
                        font.pixelSize: 18 
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["pavucontrol"])
                            hoverEnabled: true
                            onEntered: audioTooltip.requestShow()
                            onExited: audioTooltip.requestHide()
                        }
                        
                        Tooltip {
                            id: audioTooltip
                            text: "Volume: " + Math.round(Audio.volume * 100) + "%"
                            orientation: "bottom"
                            parent: win.contentItem
                            target: audioText
                        }
                    }

                    // Battery
                    Text {
                        id: battText
                        visible: UPower.displayDevice.isLaptopBattery
                        readonly property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged
                        readonly property real percentage: UPower.displayDevice.percentage * 100
                        
                        text: {
                            if (isCharging) return " " + Math.round(percentage) + "%"
                            const icons = ["", "", "", "", ""]
                            const index = Math.min(Math.floor(percentage / 20), 4)
                            return icons[index] + " " + Math.round(percentage) + "%"
                        }
                        
                        color: isCharging ? HyprUITheme.active.green : (percentage <= 15 ? HyprUITheme.active.error : (percentage <= 30 ? HyprUITheme.secondary : HyprUITheme.active.green))
                        font.family: "MesloLGS NF"
                        font.pixelSize: 14
                        font.bold: true
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: battTooltip.requestShow()
                            onExited: battTooltip.requestHide()
                        }

                        Tooltip {
                            id: battTooltip
                            text: (UPower.onBattery ? "Remaining: " : "Time to Full: ") + root.formatSeconds(UPower.onBattery ? UPower.displayDevice.timeToEmpty : UPower.displayDevice.timeToFull)
                            orientation: "bottom"
                            parent: win.contentItem
                            target: battText
                        }
                    }

                    // Night Light
                    Text {
                        text: "󱩍"
                        color: HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        font.pixelSize: 18 
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["/home/sohighman/Documentos/Scripts/toggle_night_light.sh"])
                        }
                    }
                    
                    Text {
                        text: Time.timeStr
                        color: HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Text {
                        text: ""
                        color: HyprUITheme.active.error
                        font.family: "MesloLGS NF"
                        font.pixelSize: 18 
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
