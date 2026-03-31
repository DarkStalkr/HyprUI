pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQml

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
    readonly property MprisPlayer active: {
        if (props.manualActiveIdentity) {
            const found = list.find(p => p.identity === props.manualActiveIdentity);
            if (found) return found;
        }
        return list[0] ?? null;
    }
    PersistentProperties {
        id: props
        property string manualActiveIdentity: ""
        reloadableId: "players"
    }

    IpcHandler {
        target: "mpris"

        function getActive(prop: string): string {
            const active = root.active;
            return active ? active[prop] ?? "Invalid property" : "No active player";
        }

        function list(): string {
            return root.list.map(p => p.identity).join("\n");
        }

        function togglePlaying(): void {
            root.active?.togglePlaying();
        }

        function previous(): void {
            root.active?.previous();
        }

        function next(): void {
            root.active?.next();
        }

        function stop(): void {
            root.active?.stop();
        }
    }
}
