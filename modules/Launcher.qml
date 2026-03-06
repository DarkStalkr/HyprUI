import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../services"
import "../components"

Scope {
    id: root
    required property ShellScreen screen

    // Only show on the focused monitor to avoid multi-focus issues
    readonly property bool isFocusedMonitor: Hyprland.focusedMonitor?.name === screen.name
    readonly property bool visibleState: UI.launcherVisible && isFocusedMonitor

    onVisibleStateChanged: {
        if (visibleState) {
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    property string searchQuery: ""
    property var filteredApps: []
    property int selectedIndex: 0

    function updateFilter() {
        filteredApps = Apps.search(searchQuery).slice(0, 8);
        if (selectedIndex >= filteredApps.length) selectedIndex = Math.max(0, filteredApps.length - 1);
    }

    onSearchQueryChanged: updateFilter()

    PanelWindow {
        id: win
        screen: root.screen
        visible: visibleState
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-launcher"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.4
            MouseArea { anchors.fill: parent; onClicked: UI.launcherVisible = false }
        }

        Rectangle {
            id: container
            anchors.centerIn: parent
            width: 500
            height: 500
            
            radius: HyprUITheme.active.rounding
            color: HyprUITheme.active.background
            border.color: HyprUITheme.primary
            border.width: 1
            
            opacity: visibleState ? 1.0 : 0.0
            scale: visibleState ? 1.0 : 0.9

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 10
                    color: HyprUITheme.active.surface
                    border.color: searchInput.activeFocus ? HyprUITheme.primary : "transparent"
                    border.width: 2

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        verticalAlignment: TextInput.AlignVCenter
                        color: HyprUITheme.active.text
                        font.family: "MesloLGS NF"
                        font.pixelSize: 18
                        focus: true
                        
                        onTextChanged: root.searchQuery = text
                        
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) UI.launcherVisible = false;
                            if (event.key === Qt.Key_Down) root.selectedIndex = (root.selectedIndex + 1) % Math.max(1, root.filteredApps.length);
                            if (event.key === Qt.Key_Up) root.selectedIndex = (root.selectedIndex - 1 + root.filteredApps.length) % Math.max(1, root.filteredApps.length);
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.filteredApps[root.selectedIndex]) {
                                    Apps.launch(root.filteredApps[root.selectedIndex]);
                                    UI.launcherVisible = false;
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: appListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.filteredApps
                    spacing: 5
                    clip: true

                    delegate: Rectangle {
                        id: appItem
                        width: appListView.width
                        height: 50
                        radius: 8
                        color: index === root.selectedIndex ? HyprUITheme.active.surface : "transparent"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 10

                            Image {
                                source: Quickshell.iconPath(modelData.icon, "image-missing")
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                            }

                            Text {
                                text: modelData.name
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 16
                                font.bold: index === root.selectedIndex
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.LeftButton) {
                                    Apps.launch(modelData);
                                    UI.launcherVisible = false;
                                } else {
                                    UI.pinApp(modelData.id);
                                }
                            }
                            hoverEnabled: true
                            onEntered: launchTooltip.requestShow()
                            onExited: launchTooltip.requestHide()
                        }
                        
                        Tooltip {
                            id: launchTooltip
                            text: "Left: Launch | Right: Pin"
                            parent: win.contentItem
                            target: appItem
                        }
                    }
                }
            }
        }
    }
}
