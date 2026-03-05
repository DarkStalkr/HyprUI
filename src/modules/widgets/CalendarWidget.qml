import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services"

Rectangle {
    id: root
    implicitWidth: 300
    implicitHeight: 350
    radius: HyprUITheme.active.rounding
    color: HyprUITheme.active.surface
    border.color: HyprUITheme.primary
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(new Date(), "MMMM yyyy")
            color: HyprUITheme.active.text
            font.pixelSize: 20
            font.bold: true
        }

        DayOfWeekRow {
            Layout.fillWidth: true
            delegate: Text {
                text: model.shortName
                color: HyprUITheme.active.text
                opacity: 0.7
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
        }

        MonthGrid {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            month: new Date().getMonth()
            year: new Date().getFullYear()

            delegate: Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: 5
                color: model.today ? (HyprUITheme.active.primary ?? "#cba6f7") : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: model.day
                    color: model.today ? HyprUITheme.active.background : HyprUITheme.active.text
                    opacity: model.today ? 1.0 : (model.month === grid.month ? 1.0 : 0.3)
                    font.bold: model.today
                }
            }
        }
    }
}
