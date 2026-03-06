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
        // Only show if there are notifications
        visible: Notifications.notifications.length > 0
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-notifications"
        
        anchors {
            top: true
            right: true
        }
        
        // Offset from corner
        mask: Region {} 
        
        implicitWidth: 400
        implicitHeight: 800
        color: "transparent"

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 60 // Below top bar
            spacing: 12
            model: Notifications.notifications
            
            // Smoother list transitions
            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300 }
                NumberAnimation { property: "x"; from: 100; to: 0; duration: 300; easing.type: Easing.OutQuint }
            }
            remove: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                NumberAnimation { property: "scale"; to: 0.8; duration: 200 }
            }
            displaced: Transition {
                NumberAnimation { properties: "y"; duration: 200 }
            }

            delegate: Item {
                width: listView.width - 20
                height: contentLayout.implicitHeight + 30
                anchors.horizontalCenter: parent.horizontalCenter

                // Simple shadow replacement
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    radius: 18
                    color: "black"
                    opacity: 0.2
                    transform: Translate { x: 2; y: 2 }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: HyprUITheme.active.background
                    border.color: HyprUITheme.primary
                    border.width: 1
                    opacity: 0.98

                    RowLayout {
                        id: contentLayout
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        
                        // App Icon / Image
                        Rectangle {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            radius: 10
                            clip: true
                            color: HyprUITheme.active.surface
                            
                            Image {
                                anchors.fill: parent
                                anchors.margins: 5
                                source: modelData.appIcon ? Quickshell.iconPath(modelData.appIcon) : ""
                                fillMode: Image.PreserveAspectFit
                                visible: source != ""
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                visible: parent.children[0].source == ""
                                text: "󰂚"
                                font.pixelSize: 24
                                color: HyprUITheme.active.text
                                opacity: 0.5
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.appName || "System"
                                    color: HyprUITheme.primary
                                    font.family: "MesloLGS NF"
                                    font.pixelSize: 10
                                    font.bold: true
                                    opacity: 0.8
                                    textFormat: Text.PlainText
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: Qt.formatTime(modelData.time, "hh:mm")
                                    color: HyprUITheme.active.text
                                    font.family: "MesloLGS NF"
                                    font.pixelSize: 10
                                    opacity: 0.5
                                }
                            }

                            Text {
                                text: modelData.summary
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 14
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: modelData.body
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 12
                                opacity: 0.8
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                        
                        // Close Button
                        Text {
                            text: "󰅖"
                            color: HyprUITheme.active.text
                            font.family: "MesloLGS NF"
                            font.pixelSize: 18
                            opacity: 0.5
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.opacity = 1.0
                                onExited: parent.opacity = 0.5
                                onClicked: Notifications.remove(modelData.id)
                            }
                        }
                    }
                }
                
                // Auto-hide Timer
                Timer {
                    interval: 6000 // 6 seconds
                    running: true
                    onTriggered: Notifications.remove(modelData.id)
                }
            }
        }
    }
}
