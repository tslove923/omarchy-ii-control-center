import ".."
import "../widgets"
import QtQuick
import QtQuick.Layouts

// ii WindowDialogButtonRow equivalent — the bottom-row of dialog buttons
// (e.g. Details ... Done), right-aligned like ii.
RowLayout {
    spacing: 6
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignRight
}
