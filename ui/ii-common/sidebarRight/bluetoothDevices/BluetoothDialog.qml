import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "../../"
import "../../functions"
import "../../services"
import "../../stubs"
import "../../widgets"

// Vendored from ii's .../bluetoothDevices/BluetoothDialog.qml -- ii's
// bluetooth devices configure submenu, rebuilt on this plugin's WindowDialog
// shell. Backend is Quickshell.Bluetooth directly (same as the BluetoothStatus
// service); list entries come from BluetoothStatus.friendlyDeviceList.
WindowDialog {
    id: root
    backgroundHeight: 600

    WindowDialogTitle {
        text: Translation.tr("Bluetooth devices")
    }
    WindowDialogSeparator {
        visible: !(Bluetooth.defaultAdapter?.discovering ?? false)
    }
    StyledIndeterminateProgressBar {
        visible: Bluetooth.defaultAdapter?.discovering ?? false
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
    }

    StyledListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16

        clip: true
        spacing: 0
        animateAppearance: false

        model: ScriptModel {
            values: Array.from(BluetoothStatus.friendlyDeviceList)
        }
        delegate: BluetoothDeviceItem {
            required property var modelData
            device: modelData
            anchors { left: parent?.left; right: parent?.right }
        }
    }

    WindowDialogSeparator {}
    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Details")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${Config.options.apps.bluetooth}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item { Layout.fillWidth: true }

        DialogButton {
            buttonText: Translation.tr("Done")
            onClicked: root.dismiss()
        }
    }

    // Start/refresh scanning whenever the dialog is shown.
    onVisibleChanged: {
        if (root.show) {
            Bluetooth.defaultAdapter.enabled = true;
            Bluetooth.defaultAdapter.discovering = true;
        } else {
            Bluetooth.defaultAdapter.discovering = false;
        }
    }
}
