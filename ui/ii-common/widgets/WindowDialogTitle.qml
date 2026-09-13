import ".."
import "../widgets"
import QtQuick
import QtQuick.Layouts

// ii WindowDialogTitle equivalent — the bold header at the top of a configure
// submenu. Vendored dialog content references this name directly.
StyledText {
    Layout.fillWidth: true
    font.pixelSize: Appearance.font.pixelSize.larger
    font.weight: 600
    color: Appearance.colors.colOnLayer1
}
