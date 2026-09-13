import "../../widgets"
import "../../"
import QtQuick
import QtQuick.Layouts

import "classicStyle"

// Vendored from ii's .../quickToggles/ClassicQuickPanel.qml. Per the port's
// scope, only NetworkToggle/BluetoothToggle/NightLight are included in the
// button row -- GameMode/IdleInhibitor/EasyEffectsToggle/CloudflareWarp are
// deliberately dropped (not relevant to this scaffold), matching the
// original hand-rolled toggle row this replaces.
AbstractQuickPanel {
    id: root
    Layout.alignment: Qt.AlignHCenter
    implicitWidth: buttonGroup.implicitWidth
    implicitHeight: buttonGroup.implicitHeight
    color: "transparent"

    ButtonGroup {
        id: buttonGroup
        spacing: 5
        padding: 5
        color: Appearance.colors.colLayer1

        NetworkToggle {
            altAction: () => {
                root.openWifiDialog();
            }
        }
        BluetoothToggle {
            altAction: () => {
                root.openBluetoothDialog();
            }
        }
        NightLight {}
    }
}
