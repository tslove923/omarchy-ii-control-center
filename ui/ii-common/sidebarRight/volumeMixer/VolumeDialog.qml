import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../"
import "../../services"
import "../../stubs"
import "../../widgets"

// Vendored from ii's .../volumeMixer/VolumeDialog.qml -- ii's audio
// output/input configure submenu, rebuilt on this plugin's WindowDialog shell
// (ii's own WindowDialog stack is ii-internal, not a Quickshell builtin).
// Same shell for both directions; `isSink` picks the title and which
// Audio.*AppNodes/*Devices lists VolumeDialogContent reads.
WindowDialog {
    id: root
    property bool isSink: true
    backgroundHeight: 600

    WindowDialogTitle {
        text: root.isSink ? Translation.tr("Audio output") : Translation.tr("Audio input")
    }
    WindowDialogSeparator {}

    VolumeDialogContent {
        isSink: root.isSink
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    WindowDialogSeparator {}
    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Details")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${Config.options.apps.volumeMixer}`]);
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
