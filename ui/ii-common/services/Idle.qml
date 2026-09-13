pragma Singleton
import "../"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Caffeine ("keep awake") toggle that PLUGS INTO Omarchy's own idle service
// instead of tracking a separate state of its own.
//
// Omarchy's idle service (`shell/plugins/services/idle/Service.qml`) owns the
// real "stay awake" state, persisted as the plain file
//   ~/.local/state/omarchy/indicators/stay-awake
// whose *presence* means stay-awake-on. Both omarchy's own idle service and
// its bar indicator (`bar/indicators/StayAwake.qml`) read/write that file,
// so it is the single source of truth for caffeine on the machine.
//
// This service mirrors that mechanism exactly (same file, same touch/rm
// commands as omarchy's `persistStayAwake`), so this plugin's toggle and
// omarchy's indicator never disagree. The real Wayland idle_inhibit is done
// by omarchy's idle service; this keeps a zero-size surface only so a direct
// request is also made, which is harmless redundancy.
Singleton {
    id: root

    readonly property string stateDir: `${Quickshell.env("HOME")}/.local/state/omarchy/indicators`
    readonly property string statePath: `${root.stateDir}/stay-awake`

    // True while the omarchy stay-awake file exists. Bound to the FileView
    // below so any external toggle (omarchy's own, or this one) reflects.
    property bool inhibit: false

    function toggleInhibit(active) {
        var next = (active !== undefined) ? active : !root.inhibit
        root.inhibit = next // optimistic; the watcher confirms
        Quickshell.execDetached(["bash", "-lc",
            next
                ? `mkdir -p "${root.stateDir}" && touch "${root.statePath}"`
                : `rm -f "${root.statePath}"`])
    }

    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        onLoaded: root.inhibit = true
        onLoadFailed: err => {
            if (err == FileViewError.FileNotFound) root.inhibit = false
        }
    }

    IdleInhibitor {
        id: idleInhibitor
        enabled: root.inhibit
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            anchors { right: true; bottom: true }
            mask: Region { item: null }
        }
    }
}
