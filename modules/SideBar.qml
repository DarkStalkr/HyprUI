import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Scope {
    id: root
    required property ShellScreen screen

    PanelWindow {
        id: win
        screen: root.screen
        visible: true
        
        // Changed to Overlay to ensure tooltips are on top of everything
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-sidebar"
        WlrLayershell.exclusiveZone: 60
        
        anchors {
            top: true
            bottom: true
            left: true
        }
        
        // Much wider to allow tooltips to show to the right
        implicitWidth: 400
        color: "transparent"
        
        mask: Region {
            width: 60
            height: win.height
        }

        Rectangle {
            id: barBackground
            width: 60
            height: parent.height
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
                    
                    Repeater {
                        model: UI.pinnedApps
                        AppIcon { 
                            appId: modelData 
                            onUnpin: UI.pinnedApps = UI.pinnedApps.filter(id => id !== appId)
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                // Bottom: Dashboard Toggle
                Rectangle {
                    id: dashBtn
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    width: 40
                    height: 40
                    radius: 20
                    color: UI.dashboardVisible ? HyprUITheme.primary : HyprUITheme.active.surface
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰕮"
                        font.family: "MesloLGS NF"
                        font.pixelSize: 20
                        color: UI.dashboardVisible ? HyprUITheme.active.background : HyprUITheme.active.text
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: UI.toggleDashboard()
                        hoverEnabled: true
                        onEntered: dashTooltip.requestShow()
                        onExited: dashTooltip.requestHide()
                    }
                    
                    Tooltip {
                        id: dashTooltip
                        text: "Toggle Dashboard"
                        orientation: "right"
                        parent: win.contentItem
                        target: dashBtn
                    }
                }
            }
        }
    }
    
    component AppIcon: Rectangle {
        id: iconRoot
        property string appId
        signal unpin()
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
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onEntered: {
                parent.scale = 1.1;
                appTooltip.requestShow();
            }
            onExited: {
                parent.scale = 1.0;
                appTooltip.requestHide();
            }
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (app) Apps.launch(app);
                } else {
                    unpin();
                }
            }
        }
        
        Tooltip {
            id: appTooltip
            text: app ? app.name : appId
            orientation: "right"
            parent: win.contentItem
            target: iconRoot
        }
        
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
    }
}
