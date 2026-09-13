import QtQuick
import "../../../services"
import "../../../"
import "../../../models/quickToggles"
import "../../../widgets"

// Vendored from ii's .../androidStyle/AndroidCloudflareWarpToggle.qml -- thin wrapper that
// instantiates the CloudflareWarpToggle backend in the Android grid. Only the import
// closure changed (re-pointed at this plugin's vendored ii-common tree).
AndroidQuickToggleButton {
    toggleModel: CloudflareWarpToggle {}
}
