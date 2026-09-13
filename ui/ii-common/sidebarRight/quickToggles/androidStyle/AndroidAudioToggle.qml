import QtQuick
import "../../../services"
import "../../../"
import "../../../models/quickToggles"
import "../../../widgets"

// Vendored from ii's .../androidStyle/AndroidAudioToggle.qml -- thin wrapper that
// instantiates the AudioToggle backend in the Android grid. Only the import
// closure changed (re-pointed at this plugin's vendored ii-common tree).
AndroidQuickToggleButton {
    toggleModel: AudioToggle {}
}
