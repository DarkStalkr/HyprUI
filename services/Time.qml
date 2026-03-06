pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    readonly property string timeStr: Qt.formatTime(clock.date, "hh:mm")
    readonly property string hourStr: Qt.formatTime(clock.date, "hh")
    readonly property string minuteStr: Qt.formatTime(clock.date, "mm")

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
