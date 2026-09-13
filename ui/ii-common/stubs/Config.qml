pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Minimal stand-in for illogical-impulse's ~655-line Config.qml singleton.
// Only exposes the exact option paths the vendored widget closure actually
// reads, with sane hardcoded defaults (see Config.qml's real JsonObject
// defaults in dots-hyprland for what these mirror).
//
// One subtree IS real persistence, not a hardcoded stub:
// options.sidebar.quickToggles.android.{columns,toggles} backs the
// AndroidQuickPanel's drag-to-reorder/resizable grid, which is genuinely
// user-editable (edit mode lets you add/remove/resize/reorder tiles), so it
// needs to actually survive a shell restart. Real ii backs the whole options
// tree this way already (a Quickshell.Io FileView + JsonAdapter singleton),
// so this stub just does the same thing for this one subtree -- see
// androidTogglesFileView below -- pointed at this plugin's own state dir
// (~/.local/state/omarchy/trevor.ii-control-center/, matching the convention
// Omarchy's own notifications plugin uses for its settings.json) rather than
// ii's real ~/.config/illogical-impulse/config.json, to avoid clobbering any
// separate real ii install's config on this machine.
Singleton {
    id: root

    // JsonAdapter properties have valid default values immediately, so
    // there's no real "not ready yet" state to gate on the way real ii's
    // Config.ready protects against reading before its file has loaded --
    // simplified to always-true here.
    readonly property bool ready: true

    readonly property string stateDir: `${Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")}/omarchy/trevor.ii-control-center`
    readonly property string androidTogglesPath: `${root.stateDir}/android-toggles.json`

    property QtObject options: QtObject {
        property QtObject sidebar: QtObject {
            property QtObject quickSliders: QtObject {
                property bool showBrightness: true
                property bool showVolume: true
                property bool showMic: true
            }
            property QtObject quickToggles: QtObject {
                // Real ii lets the user pick "classic" (small fixed row) or
                // "android" (this port only wires up "android", per scope).
                property string style: "android"
                property alias android: androidTogglesAdapter
            }
        }
        property QtObject apps: QtObject {
            // Launched from a toggle's right-click ("configure") action.
            property string bluetooth: "blueman-manager"
            property string network: "nm-connection-editor"
            property string networkEthernet: "nm-connection-editor"
            // "Details" button in the volume-mixer submenu -- opens the full
            // external mixer for anything the in-shell one doesn't cover.
            property string volumeMixer: "pavucontrol"
        }
        property QtObject light: QtObject {
            property QtObject night: QtObject {
                // Real ii schedules night light automatically between
                // from/to times; this plugin only exposes a manual toggle,
                // so "automatic" just tracks the right-click checkbox state
                // for icon purposes (bedtime vs night_sight_auto) without
                // actually driving a schedule.
                property bool automatic: false
                // Manual color-temperature slider in NightLightDialog, in
                // Kelvin -- forwarded straight to `hyprctl hyprsunset
                // temperature` by the Hyprsunset shim.
                property int colorTemperature: 4000
            }
        }
    }

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.stateDir])

    Timer {
        id: writeAndroidTogglesTimer
        interval: 150
        onTriggered: androidTogglesFileView.writeAdapter()
    }

    FileView {
        id: androidTogglesFileView
        path: root.androidTogglesPath
        watchChanges: true
        onAdapterUpdated: writeAndroidTogglesTimer.restart()
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound)
                writeAndroidTogglesTimer.restart();
        }
        adapter: JsonAdapter {
            id: androidTogglesAdapter
            property int columns: 4
            // Sensible default layout before the user ever drags/resizes
            // anything -- every tile here has a real, working backend (see
            // ii-common/models/quickToggles/).
            property list<var> toggles: [
                { "type": "network", "size": 1 },
                { "type": "bluetooth", "size": 1 },
                { "type": "nightLight", "size": 1 },
                { "type": "idleInhibitor", "size": 1 },
                { "type": "powerProfile", "size": 1 }
            ]
        }
    }
}
