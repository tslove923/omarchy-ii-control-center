import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/MusicRecognitionToggle.qml --
// import paths re-pointed at this plugin's vendored SongRec service (which
// drives the plugin's own copy of ii's recognize-music.sh + `songrec`).
QuickToggleModel {
    toggled: SongRec.running
    property bool sourceIsMonitor: SongRec.monitorSource === SongRec.MonitorSource.Monitor

    name: Translation.tr("Identify Music")
    statusText: toggled ? Translation.tr("Listening...") : sourceIsMonitor ? Translation.tr("System sound") : Translation.tr("Microphone")
    icon: toggled ? "music_cast" : (sourceIsMonitor ? "music_note" : "frame_person_mic")

    tooltipText: Translation.tr("Recognize music | Right-click to toggle source")

    mainAction: () => {
        SongRec.toggleRunning()
    }
    altAction: () => {
        SongRec.toggleMonitorSource()
    }
}
