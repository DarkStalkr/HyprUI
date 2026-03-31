pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

Singleton {
    id: root

    property real brightness: 0
    property bool initialized: false

    function increase() {
        set(brightness + Config.services.brightnessIncrement);
    }

    function decrease() {
        set(brightness - Config.services.brightnessIncrement);
    }

    function update() {
        getProc.running = true;
    }

    function set(value) {
        let next = Math.max(0, Math.min(1, value));
        root.brightness = next;
        
        let percent = Math.round(next * 100);
        setProc.command = ["brightnessctl", "s", percent + "%"];
        setProc.running = true;
    }

    Process {
        id: getProc
        command: ["brightnessctl", "g"]
        stdout: StdioCollector {
            onStreamFinished: {
                let current = parseInt(text);
                maxProc.running = true;
                root.tmpCurrent = current;
            }
        }
    }

    property int tmpCurrent: 0
    Process {
        id: maxProc
        command: ["brightnessctl", "m"]
        stdout: StdioCollector {
            onStreamFinished: {
                let max = parseInt(text);
                root.brightness = root.tmpCurrent / max;
                root.initialized = true;
            }
        }
    }

    Process {
        id: setProc
        onExited: update()
    }

    Timer {
        id: brightnessTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: update()
    }

    Component.onCompleted: update()
    Component.onDestruction: brightnessTimer.stop()
}
