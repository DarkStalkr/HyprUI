import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Bluetooth // Import for Bluetooth service
import "../services"

Scope {
    id: root
    required property ShellScreen screen
    // Removed property var wifiListPopup: null // No longer needed after removing WifiListPopup

    PanelWindow {
        id: win
        screen: root.screen
        visible: true
        
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "hyprui-topbar"
        WlrLayershell.exclusiveZone: 45
        
        anchors {
            top: true
            left: true
            right: true
        }
        
        implicitHeight: 45
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: HyprUITheme.active.background
            opacity: 0.95
            
            // Bottom shadow/border
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: HyprUITheme.primary
                opacity: 0.3
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                // Left: Workspaces
                RowLayout {
                    spacing: 8
                    Repeater {
                        model: Hypr.workspaces.values
                        
                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 0 // Square boxes
                            color: modelData.id === Hypr.activeWsId ? HyprUITheme.primary : HyprUITheme.active.surface
                            border.color: "transparent" // Eliminate border color
                            border.width: modelData.lastIpcObject.windows > 0 ? 1 : 0
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.id
                                color: modelData.id === Hypr.activeWsId ? HyprUITheme.active.background : HyprUITheme.active.text
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

                // Center: Window Title
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Hypr.activeToplevel?.title || "Desktop"
                    color: HyprUITheme.active.text
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    font.bold: true
                }

                // Right: Status Icons
                RowLayout {
                    spacing: 15
                    
                    // Network
                    Text {
                        id: wifiIcon
                        text: Network.wifiEnabled ? (Network.active ? "󰖩" : "󰖩") : "󰖪"
                        color: Network.active ? HyprUITheme.primary : HyprUITheme.active.text
                        font.pixelSize: 16
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["kitty", "-e", "nmtui"]) // Launch nmtui on click
                        }
                    }
                    
                    // Bluetooth
                    Text {
                        text: "󰂯"
                        color: Bluetooth.defaultAdapter?.enabled ? HyprUITheme.primary : HyprUITheme.active.text
                        opacity: 0.8
                        font.pixelSize: 16
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton // Accept both left and right clicks
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.LeftButton) {
                                    Quickshell.execDetached(["/home/sohighman/.config/hypr/scripts/bluetooth-control.sh", "toggle"]); // Left-click toggles using script
                                } else if (mouse.button === Qt.RightButton) {
                                    Quickshell.execDetached(["blueberry"]); // Right-click opens blueberry GUI
                                }
                            }
                        }
                    }
                    
                    // Audio
                    Text {
                        text: Audio.muted ? "󰝟" : "󰕾"
                        color: Audio.muted ? HyprUITheme.active.error : HyprUITheme.primary
                        font.pixelSize: 16
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["pavucontrol"]) // Launch pavucontrol on click
                        }
                    }

                    // Night Light
                    Text {
                        text: "󱩍" // Night light icon
                        color: HyprUITheme.active.text
                        font.pixelSize: 16
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["/home/sohighman/Documentos/Scripts/toggle_night_light.sh"]) // Toggle night light script
                        }
                    }
                    
                    // Clock
                    Text {
                        text: Time.timeStr
                        color: HyprUITheme.active.text
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    // Power
                    Text {
                        text: ""
                        color: HyprUITheme.active.error
                        font.pixelSize: 16
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
