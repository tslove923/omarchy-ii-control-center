pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Vendored verbatim from ii's services/EasyEffects.qml -- zero Config/
// GlobalStates coupling in the original. Real backend: the `easyeffects`
// package (installed via this plugin's setup.sh, sourced from ii's own
// sdata/dist-arch/illogical-impulse-widgets PKGBUILD note even though
// EasyEffects itself isn't a hard ii dependency -- it's opportunistic there
// too, gated on `available`).
Singleton {
    id: root

    property bool available: false
    property bool active: false

    function fetchAvailability() {
        fetchAvailabilityProc.running = true
    }

    function fetchActiveState() {
        fetchActiveStateProc.running = true
    }

    function disable() {
        root.active = false
        Quickshell.execDetached(["bash", "-c", "pkill easyeffects || flatpak pkill com.github.wwmm.easyeffects"])
    }

    function enable() {
        root.active = true
        Quickshell.execDetached(["bash", "-c", "easyeffects --hide-window --service-mode || flatpak run com.github.wwmm.easyeffects --hide-window --service-mode"])
    }

    function toggle() {
        if (root.active) {
            root.disable()
        } else {
            root.enable()
        }
    }

    Component.onCompleted: root.fetchAvailability()

    Process {
        id: fetchAvailabilityProc
        command: ["bash", "-c", "command -v easyeffects || flatpak info com.github.wwmm.easyeffects > /dev/null 2>&1"]
        onExited: (exitCode, exitStatus) => {
            root.available = exitCode === 0
        }
    }

    Process {
        id: fetchActiveStateProc
        command: ["bash", "-c", "pidof easyeffects || flatpak ps | grep com.github.wwmm.easyeffects > /dev/null 2>&1"]
        onExited: (exitCode, exitStatus) => {
            root.active = exitCode === 0
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.fetchActiveState()
    }
}
