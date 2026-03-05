import QtQuick
import QtQuick.Layouts
import "../../services"

Rectangle {
    id: root
    implicitWidth: 300
    implicitHeight: 150
    radius: HyprUITheme.active.rounding
    color: HyprUITheme.active.surface
    border.color: HyprUITheme.primary
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: Weather.icon
            font.pixelSize: 64
            color: HyprUITheme.secondary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: Weather.city || "Searching..."
                color: HyprUITheme.active.text
                font.pixelSize: 18
                font.bold: true
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }

            Text {
                text: Weather.temp
                color: HyprUITheme.active.text
                font.pixelSize: 32
                font.bold: true
            }

            Text {
                text: Weather.description
                color: HyprUITheme.active.text
                opacity: 0.8
                font.pixelSize: 14
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: Weather.reload()
    }
}
