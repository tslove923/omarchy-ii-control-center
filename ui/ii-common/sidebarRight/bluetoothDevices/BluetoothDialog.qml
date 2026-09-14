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
    //
    // This is NOT the only thing that stops discovery -- see the safety-net
    // Timer and Component.onDestruction below. Relying solely on
    // visible/root.show flipping back to false is fragile: this dialog is
    // mounted inside ControlCenter.qml's own Loader/scrim overlay, and the
    // *outer* sidebar panel can be closed (bar icon, keybind, the
    // blow-off-some-steam auto-close) via ControlCenter's own close(),
    // which historically only hid the outer panel/window and never touched
    // this dialog's `show` property -- leaving `visible` never toggled,
    // onVisibleChanged never firing, and discovery running indefinitely.
    // (Confirmed via `bluetoothctl show` showing `Discovering: yes`
    // unchanging for an extended period, cleared only by restarting
    // bluetoothd -- see ControlCenter.qml's close() for the actual fix to
    // that path.) The two backstops below exist so this dialog stops
    // discovery on its own no matter how it goes away.
    onVisibleChanged: {
        if (root.show) {
            Bluetooth.defaultAdapter.enabled = true;
            Bluetooth.defaultAdapter.discovering = true;
        } else {
            Bluetooth.defaultAdapter.discovering = false;
        }
    }

    // Safety-net: never let discovery run unbounded regardless of dialog
    // state. `running` tracks the adapter's actual discovering state (not
    // root.show), so this restarts fresh every time discovery turns on and
    // force-stops it if it's ever been on continuously past this bound --
    // a cheap backstop against this exact dismissal-path bug plus any
    // not-yet-found variant of it. Mirrors the librepods duty-cycle fix.
    Timer {
        id: discoveryTimeoutBackstop
        interval: 45000
        repeat: false
        running: Bluetooth.defaultAdapter?.discovering ?? false
        onTriggered: {
            console.warn("BluetoothDialog: safety-net stopping discovery after", interval / 1000, "s continuous");
            if (Bluetooth.defaultAdapter)
                Bluetooth.defaultAdapter.discovering = false;
        }
    }

    // Unconditional backstop: whenever this dialog instance goes away for
    // ANY reason (Loader unloading it, the whole plugin tree being torn
    // down on disable/hot-reload, etc.), make sure discovery isn't left
    // running behind it. Deliberately does not check root.show/visible --
    // destruction can happen without either ever flipping.
    Component.onDestruction: {
        if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering)
            Bluetooth.defaultAdapter.discovering = false;
    }
}
