import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Vendored from ii's .../models/quickToggles/MicToggle.qml -- import paths
// re-pointed at this plugin's vendored Audio service (direct Pipewire).
QuickToggleModel {
    name: Translation.tr("Audio input")
    statusText: toggled ? Translation.tr("Enabled") : Translation.tr("Muted")
    toggled: !Audio.source?.audio?.muted
    icon: Audio.source?.audio?.muted ? "mic_off" : "mic"
    mainAction: () => {
        Audio.toggleMicMute()
    }
    hasMenu: true

    tooltipText: Translation.tr("Audio input | Right-click for volume mixer & device selector")
}
