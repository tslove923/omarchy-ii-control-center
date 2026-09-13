pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

// Trimmed from illogical-impulse's services/SongRec.qml -- interval/timeout
// were the only Config coupling in the original (Config.options
// .musicRecognition.{interval,timeout}), hardcoded here to the same values
// ii itself defaults to (2s poll, 30s give-up). Backed by the real
// `songrec` package (installed via this plugin's setup.sh, from ii's
// sdata/dist-arch/illogical-impulse-widgets PKGBUILD) driven by this
// plugin's own copy of ii's recognize-music.sh (bin/recognize-music.sh,
// vendored verbatim -- it's pure bash+songrec+pactl, zero ii-specific
// coupling in the original).
Singleton {
    id: root

    readonly property string pluginRootDir: Qt.resolvedUrl("../../../").toString().replace("file://", "")
    readonly property string scriptPath: `${root.pluginRootDir}bin/recognize-music.sh`

    enum MonitorSource { Monitor, Input }

    property var monitorSource: SongRec.MonitorSource.Monitor
    readonly property int timeoutInterval: 2
    readonly property int timeoutDuration: 30
    readonly property bool running: recognizeMusicProc.running
    property bool manuallyStopped: false
    property var recognizedTrack: ({ title: "", subtitle: "", url: "" })

    function toggleRunning(running) {
        if (recognizeMusicProc.running && running !== true) root.manuallyStopped = true;
        recognizeMusicProc.running = (running !== undefined) ? running : !root.running;
        musicRecognizedProc.running = false;
    }

    function toggleMonitorSource(source) {
        root.monitorSource = (source !== undefined) ? source
            : (root.monitorSource === SongRec.MonitorSource.Monitor) ? SongRec.MonitorSource.Input : SongRec.MonitorSource.Monitor;
    }
    function monitorSourceToString(source) {
        return source === SongRec.MonitorSource.Monitor ? "monitor" : "input";
    }
    readonly property string monitorSourceString: monitorSourceToString(monitorSource)

    function handleRecognition(jsonText) {
        try {
            const obj = JSON.parse(jsonText);
            root.recognizedTrack = { title: obj.track.title, subtitle: obj.track.subtitle, url: obj.track.url };
            musicRecognizedProc.running = true;
        } catch (e) {
            Quickshell.execDetached(["notify-send", "Couldn't recognize music", "Perhaps what you're listening to is too niche", "-a", "ii Control Center"]);
        }
    }

    Process {
        id: recognizeMusicProc
        running: false
        command: [root.scriptPath, "-i", String(root.timeoutInterval), "-t", String(root.timeoutDuration), "-s", root.monitorSourceString]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.manuallyStopped) {
                    root.manuallyStopped = false;
                    return;
                }
                root.handleRecognition(this.text);
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 1) {
                Quickshell.execDetached(["notify-send", "Couldn't recognize music", "Make sure songrec is installed", "-a", "ii Control Center"]);
            }
        }
    }

    Process {
        id: musicRecognizedProc
        running: false
        command: ["notify-send", "Music Recognized", root.recognizedTrack.title + " - " + root.recognizedTrack.subtitle, "-a", "ii Control Center"]
    }
}
