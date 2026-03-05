import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

Scope {
    id: root
    required property ShellScreen screen

    PanelWindow {
        id: win
        screen: root.screen
        visible: true
        
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "hyprui-sidebar"
        WlrLayershell.exclusiveZone: 60
        
        anchors {
            top: true
            bottom: true
            left: true
        }
        
        implicitWidth: 60
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: HyprUITheme.active.background
            opacity: 0.95
            
            // Right border
            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: HyprUITheme.primary
                opacity: 0.3
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 60 // Leave space for TopBar
                spacing: 20
                
                // Pinned Apps
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15
                    
                    AppIcon { appId: "librewolf" }
                    AppIcon { appId: "kitty" }
                    AppIcon { appId: "thunar" }
                    AppIcon { appId: "vscodium" }
                }
                
                Item { Layout.fillHeight: true }
                
                // Bottom: Dashboard Toggle
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    width: 40
                    height: 40
                    radius: 20
                    color: UI.dashboardVisible ? HyprUITheme.primary : HyprUITheme.active.surface
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰕮"
                        font.pixelSize: 20
                        color: UI.dashboardVisible ? HyprUITheme.active.background : HyprUITheme.active.text
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: UI.toggleDashboard()
                    }
                }
            }
        }
    }
    
    component AppIcon: Rectangle {
        property string appId
        readonly property var app: DesktopEntries.applications.values.find(a => a.id.toLowerCase().includes(appId.toLowerCase()))
        
        width: 44
        height: 44
        radius: 12
        color: HyprUITheme.active.surface
        border.color: HyprUITheme.primary
        border.width: ma.containsMouse ? 1 : 0
        
        Image {
            anchors.fill: parent
            anchors.margins: 8
            source: app ? Quickshell.iconPath(app.icon) : Quickshell.iconPath("image-missing")
            fillMode: Image.PreserveAspectFit
        }
        
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.scale = 1.1
            onExited: parent.scale = 1.0
            onClicked: if (app) Apps.launch(app)
        }
        
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
    }
}
