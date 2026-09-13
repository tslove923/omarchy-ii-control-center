import QtQuick
import Quickshell.Bluetooth
import "../../services"
import "../../"
import "../../stubs"
import "../../widgets"

// Vendored from ii's .../models/quickToggles/BluetoothToggle.qml -- import
// paths re-pointed at this plugin's vendored ii-common tree (BluetoothStatus
// service + Appearance/Translation shims) instead of qs.services /
// qs.modules.common. Bluetooth backend is Quickshell.Bluetooth directly, same
// as the plugin's BluetoothStatus service.
QuickToggleModel {
    name: Translation.tr("Bluetooth")
    statusText: BluetoothStatus.firstActiveDevice?.name ?? Translation.tr("Not connected")
    tooltipText: Translation.tr("%1 | Right-click to configure").arg(
        (BluetoothStatus.firstActiveDevice?.name ?? Translation.tr("Bluetooth"))
        + (BluetoothStatus.activeDeviceCount > 1 ? ` +${BluetoothStatus.activeDeviceCount - 1}` : "")
    )
    icon: BluetoothStatus.connected ? "bluetooth_connected" : BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"

    available: BluetoothStatus.available
    toggled: BluetoothStatus.enabled
    mainAction: () => {
        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter?.enabled
    }
    hasMenu: true
}
