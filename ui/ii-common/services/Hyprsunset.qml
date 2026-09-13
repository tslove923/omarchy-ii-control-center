pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Thin shim for ii's services/Hyprsunset.qml, exposing only
// gamma/gammaLowerLimit/setGamma()/toggleTemperature()/temperatureActive/
// fetchState() as QuickSliders.qml and classicStyle/NightLight.qml expect.
// Real hyprsunset integration (not a stub around Omarchy's nightlight IPC)
// since hyprsunset is actually installed and running on this machine
// (confirmed via `pgrep hyprsunset` before writing this) -- driven the same
// way ii's own service drives it, via `hyprctl hyprsunset ...`, just
// without ii's automatic day/night scheduling (Config.options.light.night
// .automatic is a display-only checkbox here, see stubs/Config.qml).
Singleton {
    id: root

    readonly property int gammaLowerLimit: 25
    readonly property int onTemperature: 4000
    readonly property int defaultTemperature: 6000

    property int gamma: 100
    property bool temperatureActive: false

    function ensureRunning() {
        Quickshell.execDetached(["bash", "-c", "pidof hyprsunset >/dev/null || hyprsunset &"]);
    }

    function setGamma(g) {
        root.gamma = Math.max(root.gammaLowerLimit, Math.min(100, Math.round(g)));
        root.ensureRunning();
        Quickshell.execDetached(["hyprctl", "hyprsunset", "gamma", String(root.gamma)]);
    }

    function toggleTemperature(active) {
        var next = active !== undefined ? active : !root.temperatureActive;
        root.temperatureActive = next;
        root.ensureRunning();
        Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(next ? root.onTemperature : root.defaultTemperature)]);
    }

    function fetchState() {
        fetchProc.running = true;
    }

    Process {
        id: fetchProc
        command: ["bash", "-c", "hyprctl hyprsunset temperature"]
        stdout: StdioCollector {
            id: stateCollector
            onStreamFinished: {
                const output = stateCollector.text.trim();
                if (output.length === 0 || output.startsWith("Couldn't"))
                    root.temperatureActive = false;
                else
                    root.temperatureActive = (output !== String(root.defaultTemperature));
            }
        }
    }
}
