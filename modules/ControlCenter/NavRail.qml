import QtQuick
import QtQuick.Layouts
import "../../services"
import "../../components"

Item {
    id: root
    
    property int activeIndex: 0
    signal indexChanged(int index)
    property real rounding: HyprUITheme.active.rounding

    width: 80
    Layout.fillHeight: true
    
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 30
        anchors.bottomMargin: 30
        spacing: 20
        
        // User Avatar Placeholder
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 44; height: 44; radius: 22
            color: HyprUITheme.active.surface
            border.color: HyprUITheme.primary
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: ""
                font.family: "MesloLGS NF"
                color: HyprUITheme.active.text
                font.pixelSize: 20
            }
        }
        
        Item { Layout.preferredHeight: 20 }

        Repeater {
            model: [
                { icon: "", label: "System" },
                { icon: "󰝚", label: "Media" },
                { icon: "", label: "Notifications" }
            ]
            
            Item {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 48
                    height: 48
                    radius: 14
                    color: root.activeIndex === index ? HyprUITheme.primary : "transparent"
                    opacity: root.activeIndex === index ? 0.15 : 0
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }
                
                MaterialIcon {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: root.activeIndex === index ? HyprUITheme.primary : HyprUITheme.active.text
                    font.pixelSize: 26
                    opacity: root.activeIndex === index ? 1.0 : 0.5
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.activeIndex = index;
                        root.indexChanged(index);
                    }
                }
            }
        }
        
        Item { Layout.fillHeight: true }
        
        // Settings Button
//        Item {
//            Layout.preferredWidth: 60
//            Layout.preferredHeight: 60
//            Layout.alignment: Qt.AlignHCenter
//            
//            MaterialIcon {
  //              anchors.centerIn: parent
    //            text: "󰒓"
      //          color: HyprUITheme.active.text
        //        font.pixelSize: 24
          //      opacity: 0.5
            //}
            
            //MouseArea {
              //  anchors.fill: parent
               // onClicked: console.log("Open settings")
         //   }
       // }
    }
}
