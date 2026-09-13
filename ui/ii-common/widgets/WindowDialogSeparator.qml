import ".."
import "../widgets"
import QtQuick
import QtQuick.Layouts

// ii WindowDialogSeparator equivalent — a thin divider line inside a dialog.
Item {
    Layout.fillWidth: true
    implicitHeight: 1
    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.colOutlineVariant
        opacity: 0.5
    }
}
