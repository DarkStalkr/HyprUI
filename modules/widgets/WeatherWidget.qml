import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../components"

StyledWidget {
    id: root
    implicitHeight: 150
    title: "" // No title for this widget

    content: RowLayout {
        anchors.fill: parent
        spacing: 20

        Text {
            text: Weather.icon
            font.pixelSize: 64
            font.family: "Symbols Nerd Font Mono" // Set icon font to Nerd Font
            color: HyprUITheme.secondary
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: 176 // Calculated available width for text content
            spacing: 5

            Text {
                text: Weather.city || "Searching..."
                color: HyprUITheme.active.text
                font.pixelSize: 18
                font.bold: true
                // elide: Text.ElideRight // Removed to allow wrapMode
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
                // elide: Text.ElideRight // Removed to allow wrapMode
                wrapMode: Text.WordWrap
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: Weather.reload()
    }
}
