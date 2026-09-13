pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "stubs"

// Trimmed from illogical-impulse's modules/common/Persistent.qml (a big
// FileView+JsonAdapter singleton holding ~15 unrelated features' UI state --
// AI chat model, cheatsheet tab, booru settings, floating overlay
// positions, pomodoro/stopwatch...). Only the two JsonObjects the vendored
// closure actually reads/writes are kept:
//   - idle.inhibit: the "keep awake" toggle's on/off state, so it survives
//     a shell restart the same way real ii's does.
//   - sidebar.bottomGroup.{collapsed,tab}: BottomWidgetGroup's
//     collapsed/expanded state and which tab (Calendar/To Do) was open.
// Pointed at THIS PLUGIN's own state dir, not wherever a real separate ii
// install on this machine would write (see stubs/Directories.qml).
Singleton {
    id: root
    property alias states: persistentStatesJsonAdapter
    property string filePath: `${Directories.state}/states.json`

    property bool ready: false

    Timer {
        id: fileReloadTimer
        interval: 100
        repeat: false
        onTriggered: persistentStatesFileView.reload()
    }

    Timer {
        id: fileWriteTimer
        interval: 100
        repeat: false
        onTriggered: persistentStatesFileView.writeAdapter()
    }

    FileView {
        id: persistentStatesFileView
        path: root.filePath

        watchChanges: true
        onFileChanged: fileReloadTimer.restart()
        onAdapterUpdated: fileWriteTimer.restart()
        onLoaded: root.ready = true
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                fileWriteTimer.restart();
            }
        }

        adapter: JsonAdapter {
            id: persistentStatesJsonAdapter

            property JsonObject idle: JsonObject {
                property bool inhibit: false
            }

            property JsonObject sidebar: JsonObject {
                property JsonObject bottomGroup: JsonObject {
                    property bool collapsed: false
                    property int tab: 0
                }
            }
        }
    }
}
