import QtQuick
import "../../"

// Vendored verbatim from ii's .../quickToggles/AbstractQuickPanel.qml.
Rectangle {
    id: root

    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()
}
