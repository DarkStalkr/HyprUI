import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root
    
    default property alias content: contentLayout.data
    
    property string title: ""
    property string subtitle: ""
    property color accentColor: HyprUITheme.primary
    property bool flat: true // Set to true to make the "box" invisible by default
    
    radius: HyprUITheme.active.rounding / 1.5
    color: flat ? "transparent" : HyprUITheme.active.surface
    border.color: flat ? "transparent" : Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
    border.width: flat ? 0 : 1
    
    implicitHeight: mainLayout.implicitHeight + (flat ? 10 : 30)

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: flat ? 0 : 15
        spacing: 12
        
        RowLayout {
            Layout.fillWidth: true
            visible: title !== ""
            Layout.bottomMargin: flat ? 5 : 0
            
            Text {
                text: root.title
                font.bold: true
                font.pixelSize: 16 // Slightly larger title for flat style
                color: HyprUITheme.active.text
                opacity: 0.9
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: root.subtitle
                font.pixelSize: 12
                color: HyprUITheme.active.text
                opacity: 0.6
                visible: subtitle !== ""
            }
        }
        
        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            spacing: 15 // More spacing for better grouping in flat style
        }
    }
}
