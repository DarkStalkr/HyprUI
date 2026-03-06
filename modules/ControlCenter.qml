import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import "../services"
import "../components"

Scope {
    id: root
    required property ShellScreen screen

    readonly property bool isFocusedMonitor: Hypr.focusedMonitor?.name === screen.name
    readonly property bool visibleState: UI.controlCenterVisible && isFocusedMonitor

    onVisibleStateChanged: {
        if (!visibleState) {
            animationTimer.restart();
        }
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: visibleState || animationTimer.running
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-controlcenter"
        WlrLayershell.keyboardFocus: visibleState ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        
        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }
        
        color: "transparent"

        Timer {
            id: animationTimer
            interval: 300
        }

        // Invisible background for clicking out
        MouseArea {
            anchors.fill: parent
            enabled: visibleState
            onClicked: UI.controlCenterVisible = false
        }

        Rectangle {
            id: container
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            width: 450
            
            // Slide animation from right using offset
            property int offset: visibleState ? 0 : width + 20
            transform: Translate { x: container.offset }
            Behavior on offset { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

            opacity: visibleState ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            radius: HyprUITheme.active.rounding
            color: HyprUITheme.active.background
            border.color: HyprUITheme.primary
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Control Center"
                        color: HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        font.pixelSize: 24
                        font.bold: true
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "󰅖"
                        color: HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        font.pixelSize: 20
                        MouseArea {
                            anchors.fill: parent
                            onClicked: UI.controlCenterVisible = false
                        }
                    }
                }

                // Scrollable Content
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: contentColumn.implicitHeight
                    clip: true
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        spacing: 25

                        // --- SECTION: SYSTEM ---
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 15

                            // System Quick Toggles
                            GridLayout {
                                columns: 2
                                Layout.fillWidth: true
                                columnSpacing: 10
                                rowSpacing: 10
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 60
                                    radius: 12
                                    color: Network.active ? HyprUITheme.primary : HyprUITheme.active.surface
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 10
                                        Text { 
                                            text: "󰖩"
                                            color: Network.active ? HyprUITheme.active.background : HyprUITheme.active.text
                                            font.family: "MesloLGS NF"
                                            font.pixelSize: 20 
                                        }
                                        Text { 
                                            text: "Wi-Fi"
                                            color: Network.active ? HyprUITheme.active.background : HyprUITheme.active.text
                                            font.family: "MesloLGS NF"
                                            font.bold: true 
                                        }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: Quickshell.execDetached(["kitty", "-e", "nmtui"]) }
                                }
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 60
                                    radius: 12
                                    color: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? HyprUITheme.secondary : HyprUITheme.active.surface
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 10
                                        Text { 
                                            text: "󰂯"
                                            color: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? HyprUITheme.active.background : HyprUITheme.active.text
                                            font.family: "MesloLGS NF"
                                            font.pixelSize: 20 
                                        }
                                        Text { 
                                            text: "Bluetooth"
                                            color: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? HyprUITheme.active.background : HyprUITheme.active.text
                                            font.family: "MesloLGS NF"
                                            font.bold: true 
                                        }
                                    }
                                    MouseArea { 
                                        anchors.fill: parent
                                        onClicked: {
                                            if (Bluetooth.defaultAdapter) {
                                                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                                            } else {
                                                Quickshell.execDetached(["blueberry"])
                                            }
                                        }
                                        onPressAndHold: Quickshell.execDetached(["blueberry"])
                                    }
                                }
                            }

                            // Volume Slider
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                RowLayout {
                                    Text { text: "Volume"; color: HyprUITheme.active.text; font.family: "MesloLGS NF"; font.bold: true }
                                    Item { Layout.fillWidth: true }
                                    Text { text: Math.round(Audio.volume * 100) + "%"; color: HyprUITheme.active.text; font.family: "MesloLGS NF"; opacity: 0.8 }
                                }
                                Rectangle {
                                    id: volSlider
                                    Layout.fillWidth: true
                                    height: 12
                                    radius: 6
                                    color: HyprUITheme.active.surface
                                    
                                    Rectangle {
                                        width: parent.width * Math.min(1.0, Audio.volume)
                                        height: parent.height
                                        radius: 6
                                        color: HyprUITheme.primary
                                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        onPressed: (mouse) => Audio.setVolume(mouse.x / width)
                                        onPositionChanged: (mouse) => Audio.setVolume(Math.max(0, Math.min(1.5, mouse.x / width)))
                                    }
                                }
                            }

                            // Brightness Slider
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                RowLayout {
                                    Text { text: "Brightness"; color: HyprUITheme.active.text; font.family: "MesloLGS NF"; font.bold: true }
                                    Item { Layout.fillWidth: true }
                                    Text { text: Math.round(Brightness.brightness * 100) + "%"; color: HyprUITheme.active.text; font.family: "MesloLGS NF"; opacity: 0.8 }
                                }
                                Rectangle {
                                    id: brightSlider
                                    Layout.fillWidth: true
                                    height: 12
                                    radius: 6
                                    color: HyprUITheme.active.surface
                                    
                                    Rectangle {
                                        width: parent.width * Brightness.brightness
                                        height: parent.height
                                        radius: 6
                                        color: HyprUITheme.secondary
                                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        onPressed: (mouse) => Brightness.set(mouse.x / width)
                                        onPositionChanged: (mouse) => Brightness.set(Math.max(0, Math.min(1, mouse.x / width)))
                                    }
                                }
                            }
                        }

                        // --- SECTION: MEDIA ---
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            
                            Text { 
                                text: "Media"
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 18
                                font.bold: true 
                            }

                            Repeater {
                                model: Mpris.players.values
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 120
                                    radius: 15
                                    color: HyprUITheme.active.surface
                                    border.color: HyprUITheme.primary
                                    border.width: modelData.playbackState === MprisPlaybackState.Playing ? 1 : 0
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 15
                                        
                                        Rectangle {
                                            Layout.preferredWidth: 90
                                            Layout.preferredHeight: 90
                                            radius: 10
                                            clip: true
                                            color: HyprUITheme.active.background
                                            
                                            Image {
                                                anchors.fill: parent
                                                source: modelData.trackArtUrl || ""
                                                fillMode: Image.PreserveAspectCrop
                                                opacity: status === Image.Ready ? 1 : 0.3
                                            }
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                visible: parent.children[0].status !== Image.Ready
                                                text: "󰝚"
                                                font.family: "MesloLGS NF"
                                                font.pixelSize: 32
                                                color: HyprUITheme.active.text
                                            }
                                        }
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Text {
                                                text: modelData.trackTitle || "No Title"
                                                color: HyprUITheme.active.text
                                                font.family: "MesloLGS NF"
                                                font.bold: true
                                                font.pixelSize: 16
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            Text {
                                                text: {
                                                    if (Array.isArray(modelData.trackArtists)) return modelData.trackArtists.join(", ");
                                                    return modelData.trackArtist || "Unknown Artist";
                                                }
                                                color: HyprUITheme.active.text
                                                font.family: "MesloLGS NF"
                                                opacity: 0.7
                                                font.pixelSize: 14
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            
                                            Item { Layout.preferredHeight: 10 }
                                            
                                            RowLayout {
                                                spacing: 15
                                                Text { 
                                                    text: "󰒮"
                                                    color: modelData.canGoPrevious ? HyprUITheme.active.text : "gray"
                                                    font.family: "MesloLGS NF"
                                                    font.pixelSize: 20
                                                    MouseArea { anchors.fill: parent; enabled: modelData.canGoPrevious; onClicked: modelData.previous() } 
                                                }
                                                Text { 
                                                    text: (modelData.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊"
                                                    color: HyprUITheme.primary
                                                    font.family: "MesloLGS NF"
                                                    font.pixelSize: 28
                                                    MouseArea { anchors.fill: parent; onClicked: modelData.togglePlaying() }
                                                }
                                                Text { 
                                                    text: "󰒭"
                                                    color: modelData.canGoNext ? HyprUITheme.active.text : "gray"
                                                    font.family: "MesloLGS NF"
                                                    font.pixelSize: 20
                                                    MouseArea { anchors.fill: parent; enabled: modelData.canGoNext; onClicked: modelData.next() } 
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // --- SECTION: NOTIFICATIONS ---
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            
                            Text { 
                                text: "Notifications"
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 18
                                font.bold: true 
                            }

                            Text {
                                text: "No recent notifications"
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                opacity: 0.5
                                Layout.alignment: Qt.AlignCenter
                            }
                        }
                    }
                }
                
                // Bottom Info
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        id: batteryText
                        visible: UPower.displayDevice.isLaptopBattery
                        text: {
                            const perc = Math.round(UPower.displayDevice.percentage * 100);
                            const stateStr = UPower.displayDevice.state === UPowerDeviceState.Charging ? "󰂄 " : "󰁹 ";
                            let timeStr = "";
                            const seconds = UPower.onBattery ? UPower.displayDevice.timeToEmpty : UPower.displayDevice.timeToFull;
                            if (seconds > 0) {
                                const h = Math.floor(seconds / 3600);
                                const m = Math.floor((seconds % 3600) / 60);
                                timeStr = ` (${h}h ${m}m)`;
                            }
                            return stateStr + perc + "%" + timeStr;
                        }
                        color: UPower.displayDevice.state === UPowerDeviceState.Charging ? HyprUITheme.primary : HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        opacity: 0.8
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "󰅐 " + Time.timeStr
                        color: HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        opacity: 0.8
                    }
                }
            }
        }
    }
}
