import QtQuick
import "../../services"
import "../../"
import "../../stubs"

// Vendored from ii's .../models/quickToggles/AudioToggle.qml -- import paths
// re-pointed at this plugin's vendored Audio service (direct Pipewire).
QuickToggleModel {
    name: Translation.tr("Audio output")
    statusText: toggled ? Translation.tr("Unmuted") : Translation.tr("Muted")
    tooltipText: Translation.tr("Audio output | Right-click for volume mixer & device selector")
    toggled: !Audio.sink?.audio?.muted
    icon: Audio.sink?.audio?.muted ? "volume_off" : "volume_up"
    mainAction: () => {
        Audio.toggleMute()
    }
    hasMenu: true
}
