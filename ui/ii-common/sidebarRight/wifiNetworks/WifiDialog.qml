import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../"
import "../../services"
import "../../stubs"
import "../../widgets"

// Vendored from ii's .../wifiNetworks/WifiDialog.qml -- ii's wifi configure
// submenu, rebuilt on this plugin's WindowDialog shell (ii's own WindowDialog
// stack is ii-internal, not a Quickshell builtin). Backend is the Network
// service's nmcli-backed list/scan/connect/password flow
// (friendlyWifiNetworks / connectToWifiNetwork / changePassword /
// openPublicWifiPortal), which was added to the shim specifically for this.
WindowDialog {
    id: root
    backgroundHeight: 600

    WindowDialogTitle {
        text: Translation.tr("Connect to Wi-Fi")
    }
    WindowDialogSeparator {
        visible: !Network.wifiScanning
    }
    StyledIndeterminateProgressBar {
        visible: Network.wifiScanning
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
    }
    ListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16

        clip: true
        spacing: 0

        model: ScriptModel {
            values: Array.from(Network.friendlyWifiNetworks)
        }
        delegate: WifiNetworkItem {
            required property var modelData
            wifiNetwork: modelData
            width: ListView.view.width
        }
    }
    WindowDialogSeparator {}
    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Details")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${Network.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: Translation.tr("Done")
            onClicked: root.dismiss()
        }
    }
}
