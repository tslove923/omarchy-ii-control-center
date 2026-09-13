import QtQuick
import "../../../services"
import "../../../"
import "../../../models/quickToggles"
import "../../../widgets"

// Vendored from ii's .../androidStyle/AndroidDarkModeToggle.qml -- thin wrapper that
// instantiates the DarkModeToggle backend in the Android grid. Only the import
// closure changed (re-pointed at this plugin's vendored ii-common tree).
AndroidQuickToggleButton {
    toggleModel: DarkModeToggle {}
}
