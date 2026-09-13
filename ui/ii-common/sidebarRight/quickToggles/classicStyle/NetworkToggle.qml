import "../../../services"
import "../../../stubs"
import "../../../widgets"
import QtQuick
import Quickshell

// Vendored near-verbatim from ii's .../classicStyle/NetworkToggle.qml
// (base type QuickToggleButton is same-directory, auto-visible; Network
// service and Config/GlobalStates/Translation stubs come from this
// plugin's vendored ii-common/ tree instead of qs.services/qs.modules.common).
QuickToggleButton {
    toggled: Network.wifiStatus !== "disabled"
    buttonIcon: Network.materialSymbol
    onClicked: Network.toggleWifi()
    altAction: () => {
        Quickshell.execDetached(["bash", "-c", `${Network.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`])
        GlobalStates.sidebarRightOpen = false
    }
    StyledToolTip {
        text: Translation.tr("%1 | Right-click to configure").arg(Network.networkName)
    }
}
