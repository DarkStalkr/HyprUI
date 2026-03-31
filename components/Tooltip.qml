import QtQuick
import "../services"

Item {
    id: root
    
    property string text: ""
    property int delay: 1500 // Reduced to 1.5s
    property string orientation: "top" // "top", "bottom", "left", "right"
    property Item target: null // The item to position against
    
    width: label.implicitWidth + 24
    height: label.implicitHeight + 16
    
    visible: false
    opacity: 0
    z: 1000

    function updatePosition() {
        if (!target || !parent) return;
        
        // Map target coordinates to the window contentItem space
        var pos = target.mapToItem(parent, 0, 0);
        
        if (orientation === "top") {
            root.x = pos.x + (target.width - root.width) / 2;
            root.y = pos.y - root.height - 10;
        } else if (orientation === "bottom") {
            root.x = pos.x + (target.width - root.width) / 2;
            root.y = pos.y + target.height + 10;
        } else if (orientation === "left") {
            root.x = pos.x - root.width - 10;
            root.y = pos.y + (target.height - root.height) / 2;
        } else if (orientation === "right") {
            root.x = pos.x + target.width + 10;
            root.y = pos.y + (target.height - root.height) / 2;
        }
    }

    Component.onDestruction: showTimer.stop()

    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: {
            root.updatePosition();
            root.visible = true;
            root.opacity = 1;
        }
    }
    
    function requestShow() {
        if (!root.visible && !showTimer.running) {
            showTimer.restart();
        }
    }
    
    function requestHide() {
        showTimer.stop();
        root.opacity = 0;
        root.visible = false;
    }

    Rectangle {
        anchors.fill: parent
        color: HyprUITheme.active.background
        radius: 10
        border.color: HyprUITheme.primary
        border.width: 1
        
        // Shadow
        Rectangle {
            anchors.fill: parent
            z: -1
            color: "black"
            opacity: 0.3
            radius: 10
            transform: Translate { x: 2; y: 2 }
        }
    }
    
    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: HyprUITheme.active.text
        font.family: "MesloLGS NF"
        font.pixelSize: 13
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }
    
    Behavior on opacity { 
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic } 
    }
}
