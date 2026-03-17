import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Scope {
    id: root
    required property ShellScreen screen

    property var activeNotif: null
    property var queue: []
    property bool alive: true

    // Snapshot properties to avoid dangling QObject references
    property string currentSummary: ""
    property string currentBody: ""
    property string currentAppName: ""
    property string currentAppIcon: ""
    property string currentImage: ""
    property var currentTime: new Date()

    onActiveNotifChanged: {
        if (activeNotif) {
            currentSummary = activeNotif.summary || "";
            currentBody = activeNotif.body || "";
            currentAppName = activeNotif.appName || "System";
            currentAppIcon = activeNotif.appIcon || "";
            currentImage = activeNotif.image || "";
            currentTime = activeNotif.time || new Date();
        }
    }

    Component.onDestruction: {
        alive = false;
        activeNotif = null;
        displayTimer.stop();
        nextTimer.stop();
        closeGuardTimer.stop();
    }
    
    // Watch the notifications list from service
    Connections {
        target: Notifications
        function onNotificationsChanged() {
            if (!root.alive) return;
            const list = Notifications.notifications;
            if (list.length > 0) {
                // If we have new items, add them to our queue if they aren't already there or currently active
                for (let i = list.length - 1; i >= 0; i--) {
                    const item = list[i];
                    const inQueue = queue.some(q => q.id === item.id);
                    const isActive = activeNotif && activeNotif.id === item.id;
                    
                    if (!inQueue && !isActive) {
                        queue.push(item);
                    }
                }
                processQueue();
            }
        }
    }

    function processQueue() {
        if (!root.alive) return;
        if (!activeNotif && queue.length > 0) {
            activeNotif = queue.shift();
            displayTimer.restart();
            closeGuardTimer.stop();
        }
    }

    function discard() {
        if (!root.alive) return;
        if (activeNotif) {
            Notifications.remove(activeNotif.id);
            activeNotif = null;
            
            // Start the guard timer to prevent the PanelWindow from closing immediately
            // if another notification is queued and about to be processed.
            closeGuardTimer.restart();
            
            // Short delay before showing next one to allow exit animation to complete
            nextTimer.restart();
        }
    }

    Timer {
        id: displayTimer
        interval: 3000 // 3 seconds as requested
        onTriggered: {
            if (root.alive) {
                discard();
            }
        }
    }

    Timer {
        id: nextTimer
        interval: 500 // Delay between notifications
        onTriggered: {
            if (root.alive) {
                processQueue();
            }
        }
    }

    Timer {
        id: closeGuardTimer
        interval: 50 // Buffer to prevent close-during-incubation
        onTriggered: {}
    }

    PanelWindow {
        id: win
        screen: root.screen
        visible: (activeNotif !== null || exitAnimation.running || closeGuardTimer.running) && root.alive
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hyprui-notifications"
        
        anchors {
            top: true
            right: true
        }
        
        implicitWidth: 440
        implicitHeight: 600 // Increased height to prevent cropping
        color: "transparent"

        Item {
            id: container
            width: 400
            height: notificationCard.height
            anchors.top: parent.top
            anchors.topMargin: 70 // Leave space below TopBar (57px)
            anchors.right: parent.right
            anchors.rightMargin: 20
            
            // State-based visibility for animations
            opacity: activeNotif !== null ? 1.0 : 0.0
            scale: activeNotif !== null ? 1.0 : 0.9
            
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
            
            // Slide animation
            property int offset: activeNotif !== null ? 0 : 50
            transform: Translate { x: container.offset }
            Behavior on offset { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }

            // Sequential appearance helper
            NumberAnimation {
                id: exitAnimation
                target: container
                property: "opacity"
                to: 0
                duration: 300
            }

            Rectangle {
                id: notificationCard
                width: parent.width
                height: contentLayout.implicitHeight + 32
                radius: 20
                color: HyprUITheme.active.background
                border.color: Qt.rgba(HyprUITheme.primary.r, HyprUITheme.primary.g, HyprUITheme.primary.b, 0.4)
                border.width: 1
                clip: true

                // Full card click to discard
                MouseArea {
                    anchors.fill: parent
                    onClicked: discard()
                }

                RowLayout {
                    id: contentLayout
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    // App Icon / Image
                    Rectangle {
                        Layout.preferredWidth: 54
                        Layout.preferredHeight: 54
                        radius: 12
                        color: HyprUITheme.active.surface
                        clip: true
                        
                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: {
                                if (currentImage !== "") return currentImage;
                                if (currentAppIcon !== "") return Quickshell.iconPath(currentAppIcon);
                                return "";
                            }
                            fillMode: Image.PreserveAspectFit
                            visible: source != ""
                        }
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            visible: !parent.children[0].visible
                            text: "󰂚"
                            font.pixelSize: 28
                            opacity: 0.5
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: currentAppName
                                color: HyprUITheme.primary
                                font.family: "MesloLGS NF"
                                font.pixelSize: 11
                                font.bold: true
                                opacity: 0.8
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Qt.formatTime(currentTime, "hh:mm")
                                color: HyprUITheme.active.text
                                font.family: "MesloLGS NF"
                                font.pixelSize: 11
                                opacity: 0.4
                            }
                        }

                        Text {
                            text: currentSummary
                            color: HyprUITheme.active.text
                            font.family: "MesloLGS NF"
                            font.pixelSize: 15
                            font.bold: true
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: currentBody
                            color: HyprUITheme.active.text
                            font.family: "MesloLGS NF"
                            font.pixelSize: 13
                            opacity: 0.7
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
