import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

Scope {
    id: root
    required property ShellScreen screen

    readonly property bool isSegmented: HyprUITheme.active.segmented ?? false
    readonly property bool visibleState: hideTimer.running

    property string mode: "volume" // "volume" or "brightness"
    property real value: mode === "volume" ? Audio.volume : Brightness.brightness

    Connections {
        target: Audio
        function onVolumeChanged() { 
            root.mode = "volume";
            hideTimer.restart(); 
        }
        function onMutedChanged() { 
            root.mode = "volume";
            hideTimer.restart(); 
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            if (Brightness.initialized) {
                root.mode = "brightness";
                hideTimer.restart();
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1800
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: visibleState
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-osd"
        WlrLayershell.exclusiveZone: -1
        
        anchors {
            bottom: true
            left: true
            right: true
        }
        
        implicitHeight: 120
        color: "transparent"

        Rectangle {
            id: container
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            
            width: 320
            height: 70
            
            radius: HyprUITheme.active.rounding
            color: HyprUITheme.active.background
            border.color: mode === "volume" ? HyprUITheme.primary : HyprUITheme.secondary
            border.width: isSegmented ? 0 : 1.5
            
            opacity: visibleState ? 1.0 : 0.0
            scale: visibleState ? 1.0 : 0.85

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
            Behavior on border.color { ColorAnimation { duration: 200 } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                Text {
                    text: mode === "volume" ? (Audio.muted ? "󰝟" : "󰕾") : "󰃠"
                    font.pixelSize: 22
                    color: mode === "volume" ? (Audio.muted ? HyprUITheme.active.error : HyprUITheme.primary) : HyprUITheme.secondary
                }

                // Bar Layout
                Row {
                    Layout.fillWidth: true
                    Layout.preferredHeight: isSegmented ? 24 : 8
                    spacing: isSegmented ? 4 : 0
                    
                    // Standard Bar
                    Rectangle {
                        visible: !isSegmented
                        width: parent.width
                        height: parent.height
                        radius: 4
                        color: HyprUITheme.active.surface

                        Rectangle {
                            width: parent.width * Math.min(root.value, 1.0)
                            height: parent.height
                            radius: 4
                            color: mode === "volume" ? HyprUITheme.primary : HyprUITheme.secondary
                            Behavior on width { NumberAnimation { duration: 100 } }
                        }
                    }

                    // Segmented macOS Bar
                    Repeater {
                        model: isSegmented ? 16 : 0
                        Rectangle {
                            width: (parent.width - (15 * 4)) / 16
                            height: parent.height
                            radius: 2
                            color: (index / 16) < root.value ? (mode === "volume" ? HyprUITheme.primary : HyprUITheme.secondary) : "rgba(69, 71, 90, 0.3)"
                        }
                    }
                }

                Text {
                    text: Math.round(root.value * 100) + "%"
                    font.pixelSize: 14
                    font.bold: true
                    color: HyprUITheme.active.text
                    width: 35
                }
            }
        }
    }
}
