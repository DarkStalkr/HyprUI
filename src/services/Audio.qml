pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property var sinks: Pipewire.nodes.values.filter(node => !node.isStream && node.isSink)
    readonly property var sources: Pipewire.nodes.values.filter(node => !node.isStream && node.audio && !node.isSink)
    readonly property var streams: Pipewire.nodes.values.filter(node => node.isStream && node.audio)

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0

    function setVolume(newVolume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1.5, newVolume)); // Max 150%
        }
    }

    function toggleMute(): void {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted;
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}
