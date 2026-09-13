import QtQuick
import "../../services"
import "../../"
import "../../stubs"

// Vendored from ii's .../models/quickToggles/NetworkToggle.qml -- import paths
// re-pointed at this plugin's vendored Network service (nmcli-backed).
QuickToggleModel {
    name: Translation.tr("Internet")
    statusText: Network.networkName
    tooltipText: Translation.tr("%1 | Right-click to configure").arg(Network.networkName)
    icon: Network.materialSymbol

    toggled: Network.wifiStatus !== "disabled"
    mainAction: () => Network.toggleWifi()
    hasMenu: true
}
