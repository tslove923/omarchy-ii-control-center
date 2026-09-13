pragma Singleton
import Quickshell

// Trimmed from illogical-impulse's modules/common/Icons.qml (a grab-bag of
// icon-name-mapping helpers) -- only getBluetoothDeviceMaterialSymbol is
// referenced by the vendored BluetoothDeviceItem.qml closure, vendored
// verbatim (zero Config/service coupling in the original).
Singleton {
    id: root

    function getBluetoothDeviceMaterialSymbol(systemIconName) {
        if (systemIconName.includes("headset") || systemIconName.includes("headphones"))
            return "headphones";
        if (systemIconName.includes("audio"))
            return "speaker";
        if (systemIconName.includes("phone"))
            return "smartphone";
        if (systemIconName.includes("mouse"))
            return "mouse";
        if (systemIconName.includes("keyboard"))
            return "keyboard";
        return "bluetooth";
    }
}
