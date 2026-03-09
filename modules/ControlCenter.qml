import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import "ControlCenter"
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
        
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        Timer { id: animationTimer; interval: 350 }

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
            anchors.margins: 12
            width: 520
            
            property int offset: visibleState ? 0 : width + 50
            transform: Translate { x: container.offset }
            Behavior on offset { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }

            opacity: visibleState ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            radius: HyprUITheme.active.rounding
            color: HyprUITheme.active.background
            border.color: Qt.rgba(HyprUITheme.primary.r, HyprUITheme.primary.g, HyprUITheme.primary.b, 0.4)
            border.width: 1
            clip: true
            
            RowLayout {
                anchors.fill: parent
                spacing: 0
                
                NavRail {
                    id: navRail
                    activeIndex: stack.currentIndex
                    onIndexChanged: (index) => stack.currentIndex = index
                    rounding: container.radius
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 25
                    spacing: 20
                    
                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        
                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: {
                                    switch(stack.currentIndex) {
                                        case 0: return "System";
                                        case 1: return "Media";
                                        case 2: return "Notifications";
                                        default: return "Settings";
                                    }
                                }
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 24
                                font.bold: true
                            }
                            Text {
                                text: {
                                    switch(stack.currentIndex) {
                                        case 0: return "Status & Settings";
                                        case 1: return "Now Playing";
                                        case 2: return "Recent Activity";
                                        default: return "Manage options";
                                    }
                                }
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 12
                                opacity: 0.5
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        IconButton {
                            icon: "󰅖"
                            onClicked: UI.controlCenterVisible = false
                        }
                    }

                    StackLayout {
                        id: stack
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: 0
                        
                        // --- PANE: SYSTEM ---
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 20

                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentHeight: systemScrollColumn.implicitHeight
                                clip: true
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                
                                ColumnLayout {
                                    id: systemScrollColumn
                                    width: parent.width
                                    spacing: 30 
                                    
                                    StyledCard {
                                        title: "Connectivity"
                                        Layout.fillWidth: true
                                        flat: true
                                        
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 12
                                            ToggleTile {
                                                label: "Wi-Fi"
                                                icon: "󰖩"
                                                active: Network.active
                                                onClicked: Quickshell.execDetached(["kitty", "-e", "nmtui"])
                                            }
                                            ToggleTile {
                                                label: "Bluetooth"
                                                icon: "󰂯"
                                                active: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
                                                onClicked: {
                                                    if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                                                }
                                            }
                                        }
                                    }
                                    
                                    StyledCard {
                                        title: "Audio & Display"
                                        Layout.fillWidth: true
                                        flat: true
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 25

                                            ModernSlider {
                                                label: "Output Volume"
                                                icon: "󰕾"
                                                iconSize: 24 
                                                value: Audio.volume
                                                accentColor: HyprUITheme.primary
                                                onMoved: (v) => Audio.setVolume(v)
                                            }
                                            
                                            ModernSlider {
                                                label: "Backlight"
                                                icon: "󰃠"
                                                iconSize: 24 
                                                value: Brightness.brightness
                                                accentColor: HyprUITheme.secondary
                                                onMoved: (v) => Brightness.set(v)
                                            }
                                        }
                                    }
                                    
                                    Item { Layout.fillHeight: true; visible: systemScrollColumn.implicitHeight < parent.height }
                                }
                            }

                            StyledCard {
                                title: "Power & Session"
                                Layout.fillWidth: true
                                flat: true
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 15
                                    
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 15
                                        MaterialIcon { text: "󰁹"; opacity: 0.7; font.pixelSize: 24 }
                                        ColumnLayout {
                                            spacing: 2
                                            Text { text: "Battery: " + Math.round(UPower.displayDevice.percentage * 100) + "%"; color: HyprUITheme.active.text; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                            Text { text: UPower.displayDevice.state === UPowerDeviceState.Charging ? "Charging" : "On Battery"; color: HyprUITheme.active.text; font.pixelSize: 11; opacity: 0.6; elide: Text.ElideRight; Layout.fillWidth: true }
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text { 
                                            text: {
                                                const s = UPower.onBattery ? UPower.displayDevice.timeToEmpty : UPower.displayDevice.timeToFull;
                                                if (s <= 0) return "";
                                                return Math.floor(s/3600) + "h " + Math.floor((s%3600)/60) + "m";
                                            }
                                            color: HyprUITheme.active.text; opacity: 0.7 
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true; spacing: 10
                                        SessionButton { icon: "󰐥"; label: "Power Off"; btnColor: HyprUITheme.active.error; onClicked: Quickshell.execDetached(["shutdown", "now"]) }
                                        SessionButton { icon: "󰑐"; label: "Reboot"; btnColor: HyprUITheme.secondary; onClicked: Quickshell.execDetached(["reboot"]) }
                                        SessionButton { icon: "󰍃"; label: "Logout"; btnColor: HyprUITheme.primary; onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "exit"]) }
                                    }
                                }
                            }
                        }
                        
                        // --- PANE: MEDIA ---
                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentHeight: mediaColumn.implicitHeight
                            clip: true
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            
                            ColumnLayout {
                                id: mediaColumn
                                width: parent.width
                                spacing: 20
                                
                                Repeater {
                                    model: Mpris.players.values
                                    
                                    StyledCard {
                                        Layout.fillWidth: true
                                        flat: true
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 15
                                            
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 20
                                                Rectangle {
                                                    width: 100; height: 100; radius: 15; clip: true
                                                    color: HyprUITheme.active.surface
                                                    Image {
                                                        anchors.fill: parent
                                                        source: modelData.trackArtUrl || ""
                                                        fillMode: Image.PreserveAspectCrop
                                                    }
                                                    MaterialIcon { anchors.centerIn: parent; text: "󰝚"; font.pixelSize: 40; opacity: 0.3; visible: !parent.children[0].status === Image.Ready }
                                                }
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 4
                                                    Text { text: modelData.trackTitle || "No Title"; color: HyprUITheme.active.text; font.bold: true; font.pixelSize: 18; elide: Text.ElideRight; Layout.fillWidth: true }
                                                    Text { text: modelData.trackArtist || "Unknown Artist"; color: HyprUITheme.active.text; opacity: 0.6; font.pixelSize: 14; elide: Text.ElideRight; Layout.fillWidth: true }
                                                    Text { text: modelData.identity || "Player"; color: HyprUITheme.primary; opacity: 0.8; font.pixelSize: 12; font.italic: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                                    
                                                    RowLayout {
                                                        Layout.topMargin: 10; spacing: 20
                                                        IconButton { icon: "󰒮"; onClicked: modelData.previous() }
                                                        IconButton { icon: modelData.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"; fontScale: 1.8; onClicked: modelData.togglePlaying() }
                                                        IconButton { icon: "󰒭"; onClicked: modelData.next() }
                                                    }
                                                }
                                            }
                                            
                                            // Player Volume Bar removed as requested
                                        }
                                    }
                                }
                                
                                StyledCard {
                                    visible: Mpris.players.values.length === 0
                                    Layout.fillWidth: true
                                    flat: true
                                    Text { text: "No active media players"; color: HyprUITheme.active.text; opacity: 0.5; Layout.alignment: Qt.AlignCenter }
                                }
                            }
                        }
                        
                        // --- PANE: NOTIFICATIONS ---
                        ColumnLayout {
                            spacing: 20
                            Layout.fillHeight: true
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Recent Activity"; color: HyprUITheme.active.text; font.bold: true; opacity: 0.7 }
                                Item { Layout.fillWidth: true }
                                TextButton { text: "Clear All"; onClicked: console.log("Clear All Notifs") }
                            }
                            
                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentHeight: notifColumn.implicitHeight
                                clip: true
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                
                                ColumnLayout {
                                    id: notifColumn
                                    width: parent.width
                                    spacing: 12
                                    
                                    Repeater {
                                        model: 1 // Mock data
                                        StyledCard {
                                            Layout.fillWidth: true
                                            flat: true
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 15
                                                Rectangle { width: 44; height: 44; radius: 22; color: HyprUITheme.primary; opacity: 0.1; MaterialIcon { anchors.centerIn: parent; text: "󰵠"; color: HyprUITheme.primary; font.pixelSize: 20 } }
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2
                                                    Text { text: "System Update"; color: HyprUITheme.active.text; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                                    Text { text: "A new version of HyprUI is available."; color: HyprUITheme.active.text; font.pixelSize: 12; opacity: 0.6; elide: Text.ElideRight; Layout.fillWidth: true }
                                                }
                                            }
                                        }
                                    }
                                    
                                    Item { Layout.fillHeight: true }
                                }
                            }
                        }
                    }
                    
                    // Footer
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Text { text: "HyprUI OS"; color: HyprUITheme.active.text; opacity: 0.4; font.italic: true }
                        Item { Layout.fillWidth: true }
                        Text { text: Time.timeStr; color: HyprUITheme.active.text; font.bold: true; opacity: 0.7 }
                    }
                }
            }
        }
    }
    
    // Internal Components
    component IconButton: Rectangle {
        property string icon: ""
        property real fontScale: 1.0
        signal clicked()
        width: 44; height: 44; radius: 22; color: "transparent"
        MaterialIcon { anchors.centerIn: parent; text: icon; font.pixelSize: 22 * fontScale; color: HyprUITheme.active.text }
        MouseArea { anchors.fill: parent; onClicked: parent.clicked(); hoverEnabled: true; onEntered: parent.color = Qt.rgba(1,1,1,0.08); onExited: parent.color = "transparent" }
    }
    
    component ToggleTile: Rectangle {
        property string label: ""
        property string icon: ""
        property bool active: false
        signal clicked()
        Layout.fillWidth: true; height: 64; radius: 14
        color: active ? HyprUITheme.primary : HyprUITheme.active.surface
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 15; anchors.rightMargin: 15; spacing: 12
            MaterialIcon { text: icon; color: active ? HyprUITheme.active.background : HyprUITheme.active.text; font.pixelSize: 22 }
            Text { text: label; color: active ? HyprUITheme.active.background : HyprUITheme.active.text; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
        }
        MouseArea { anchors.fill: parent; onClicked: parent.clicked() }
    }
    
    component ModernSlider: ColumnLayout {
        property string label: ""
        property string icon: ""
        property int iconSize: 20
        property real value: 0
        property color accentColor: HyprUITheme.primary
        signal moved(real val)
        Layout.fillWidth: true; spacing: 10
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            MaterialIcon { text: icon; font.pixelSize: iconSize; opacity: 0.7 }
            Text { text: label; color: HyprUITheme.active.text; font.pixelSize: 14; font.bold: true; opacity: 0.9; elide: Text.ElideRight; Layout.fillWidth: true }
            Text { text: Math.round(value * 100) + "%"; color: HyprUITheme.active.text; font.pixelSize: 12; opacity: 0.6 }
        }
        Rectangle {
            Layout.fillWidth: true; height: 10; radius: 5; color: Qt.rgba(1,1,1,0.08)
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1.0, value)); height: parent.height; radius: 5; color: accentColor
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
            }
            MouseArea {
                anchors.fill: parent
                onPressed: (mouse) => moved(mouse.x / width)
                onPositionChanged: (mouse) => moved(Math.max(0, Math.min(1.0, mouse.x / width)))
            }
        }
    }

    component SessionButton: Rectangle {
        property string icon: ""
        property string label: ""
        property color btnColor: HyprUITheme.primary
        signal clicked()
        Layout.fillWidth: true; height: 74; radius: 15; color: HyprUITheme.active.surface
        border.color: Qt.rgba(btnColor.r, btnColor.g, btnColor.b, 0.3); border.width: 1
        ColumnLayout {
            anchors.centerIn: parent; spacing: 4
            MaterialIcon { text: icon; color: btnColor; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
            Text { text: label; color: HyprUITheme.active.text; font.pixelSize: 11; font.bold: true; Layout.alignment: Qt.AlignHCenter }
        }
        MouseArea { anchors.fill: parent; onClicked: parent.clicked(); hoverEnabled: true; onEntered: parent.opacity = 0.8; onExited: parent.opacity = 1.0 }
    }

    component TextButton: Rectangle {
        property string text: ""
        signal clicked()
        width: label.implicitWidth + 24; height: 34; radius: 17; color: Qt.rgba(1,1,1,0.08)
        Text { id: label; anchors.centerIn: parent; text: parent.text; color: HyprUITheme.active.text; font.pixelSize: 12; font.bold: true }
        MouseArea { anchors.fill: parent; onClicked: parent.clicked(); hoverEnabled: true; onEntered: parent.color = Qt.rgba(1,1,1,0.15); onExited: parent.color = Qt.rgba(1,1,1,0.08) }
    }
}
