pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Thin shim for ii's services/Brightness.qml, exposing only
// getMonitorForScreen(screen).{brightness,setBrightness()} as
// QuickSliders.qml expects. Backed by brightnessctl (laptop backlight
// only, matching this machine) instead of ii's real ddcutil+brightnessctl
// dual-backend BrightnessMonitor -- same brightnessctl logic the plugin's
// original hand-rolled brightness slider used, just relocated here. The
// `screen` argument is accepted but ignored (single shared monitor object)
// since this machine has one backlight.
Singleton {
    id: root

    property QtObject _monitor: QtObject {
        property real brightness: 0.5
        function setBrightness(v) {
            var pct = Math.max(0, Math.min(1, v));
            brightness = pct;
            setProc.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"];
            setProc.running = true;
        }
    }

    function getMonitorForScreen(screen) {
        return root._monitor;
    }

    function refresh() {
        getProc.running = true;
    }

    Component.onCompleted: root.refresh()

    Process {
        id: getProc
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: line => {
                // Format: device,class,current,PERCENT%,max
                var fields = line.split(",");
                if (fields.length >= 4) {
                    var pct = parseInt(fields[3]);
                    if (!isNaN(pct))
                        root._monitor.brightness = pct / 100;
                }
            }
        }
    }
    Process {
        id: setProc
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
