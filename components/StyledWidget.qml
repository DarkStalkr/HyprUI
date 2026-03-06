import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root
    
    property alias content: contentItem.data
    property string title: ""
    property int padding: 20
    
    implicitWidth: 300
    implicitHeight: 350
    radius: HyprUITheme.active.rounding
    color: HyprUITheme.active.surface
    border.color: HyprUITheme.primary
    border.width: 1
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: 15
        
        Text {
            visible: text !== ""
            Layout.alignment: Qt.AlignHCenter
            text: root.title
            color: HyprUITheme.active.text
            font.pixelSize: 20
            font.bold: true
        }
        
        Item {
            id: contentItem
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
