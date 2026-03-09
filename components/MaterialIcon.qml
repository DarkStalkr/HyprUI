import QtQuick
import "../services"

Text {
    id: root
    font.family: "MesloLGS NF"
    font.pixelSize: 20
    color: HyprUITheme.active.text
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    
    property bool fill: false
    // Map material icon names to Nerd Font hex codes if needed, 
    // but for now we'll just pass the Nerd Font character directly.
}
