import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../services"
import "./widgets"

Scope {
    id: root
    required property ShellScreen screen

    readonly property bool isFocusedMonitor: Hypr.focusedMonitor?.name === screen.name
    readonly property bool visibleState: UI.dashboardVisible && isFocusedMonitor

    PanelWindow {
        id: win
        screen: root.screen
        visible: visibleState
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-dashboard"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        color: "transparent"

        // Background Dim/Blur
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.6
            
            MouseArea {
                anchors.fill: parent
                onClicked: UI.dashboardVisible = false
            }
        }

        // Dashboard Content
        ColumnLayout {
            anchors.centerIn: parent
            width: 800
            spacing: 30
            
            opacity: visibleState ? 1.0 : 0.0
            scale: visibleState ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

            // Clock & Greeting
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Time.timeStr
                    color: "white"
                    font.pixelSize: 120
                    font.bold: true
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Time.format("dddd, MMMM d")
                    color: "white"
                    font.pixelSize: 24
                    opacity: 0.8
                }
            }

            // Grid of Widgets
            GridLayout {
                columns: 2
                columnSpacing: 20
                rowSpacing: 20
                Layout.alignment: Qt.AlignHCenter

                WeatherWidget {}
                CalendarWidget {}
                
                // We can add more here like a dedicated Large Media Player
                // For now let's reuse MediaPanel logic or similar
            }
        }
    }
}
