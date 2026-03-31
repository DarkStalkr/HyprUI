import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

Scope {
    id: root
    required property ShellScreen screen

    property bool active: false
    readonly property bool visibleState: active || hideTimer.running

    property string mode: "volume" // "volume" or "brightness"
    property real value: mode === "volume" ? Audio.volume : Brightness.brightness

    Connections {
        target: Audio
        function onVolumeChanged() { 
            root.mode = "volume";
            root.active = true;
            hideTimer.restart(); 
        }
        function onMutedChanged() { 
            root.mode = "volume";
            root.active = true;
            hideTimer.restart(); 
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            if (Brightness.initialized) {
                root.mode = "brightness";
                root.active = true;
                hideTimer.restart();
            }
        }
    }

    Component.onDestruction: {
        hideTimer.stop();
    }

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: root.active = false
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: visibleState || container.opacity > 0
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-osd"
        WlrLayershell.exclusiveZone: -1
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        color: "transparent"

        Rectangle {
            id: container
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80 // Matching your GTK-layer-shell margin
            
            width: 380 // Larger
            height: 100 // Increased from 90 to fit larger icon
            
            radius: 24 // 24px as in your C snippet
            color: HyprUITheme.active.background
            border.color: mode === "volume" ? (Audio.muted ? HyprUITheme.active.error : HyprUITheme.primary) : HyprUITheme.secondary
            border.width: 2
            
            opacity: visibleState ? 1.0 : 0.0
            scale: visibleState ? 1.0 : 0.9

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: Icons.getOsdIcon(root.mode, root.value, Audio.muted)
                    font.family: "MesloLGS NF"
                    font.pixelSize: 36 // Increased from 28
                    color: mode === "volume" ? (Audio.muted ? HyprUITheme.active.error : HyprUITheme.primary) : HyprUITheme.secondary
                }

                // Thicker Progress Bar (32px)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32 // 32px height as requested
                    radius: 16
                    color: HyprUITheme.active.surface // trough color

                    Rectangle {
                        width: parent.width * Math.min(root.value, 1.0)
                        height: parent.height
                        radius: 16
                        color: mode === "volume" ? (Audio.muted ? HyprUITheme.active.error : HyprUITheme.primary) : HyprUITheme.secondary
                        
                        Behavior on width { 
                            NumberAnimation { 
                                duration: 100
                                easing.type: Easing.OutCubic
                            } 
                        }
                    }
                }
                
                // Percentage label removed as requested
            }
        }
    }
}
