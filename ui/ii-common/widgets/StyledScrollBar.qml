import QtQuick
import QtQuick.Controls
import ".."
import "../functions"

// Vendored from ii's .../widgets/StyledScrollBar.qml -- import paths
// re-pointed at this plugin's vendored ii-common tree. Slim Material
// scrollbar used by StyledListView.
ScrollBar {
    id: root

    policy: ScrollBar.AsNeeded
    topPadding: Appearance.rounding.normal
    bottomPadding: Appearance.rounding.normal
    active: hovered || pressed

    contentItem: Rectangle {
        implicitWidth: 4
        implicitHeight: root.visualSize
        radius: width / 2
        color: Appearance.colors.colOnSurfaceVariant
        
        opacity: root.policy === ScrollBar.AlwaysOn || (root.active && root.size < 1.0) ? 0.5 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Appearance.animation.elementMoveFast.type
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }
    }
}
