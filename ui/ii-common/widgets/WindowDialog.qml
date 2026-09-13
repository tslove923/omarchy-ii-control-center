import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import "../"
import "../widgets"

// ii WindowDialog EQUIVALENT for this plugin.
//
// Real ii's configure submenus (volume mixer / wifi / bluetooth) FILL the
// sidebar content area and OVERLAY the widgets beneath them (the reference
// SidebarRightContent mounts each dialog via a ToggleDialog Loader that
// `anchors.fill: parent`, i.e. it covers the sliders/toggles/calendar). The
// type itself (`WindowDialog`) lives inside ii's `qs` module and is NOT a
// Quickshell builtin, so this plugin reimplements it as an in-panel overlay.
//
// An instance is declared inside the ControlCenter (or a dialog host) and
// filled to the panel's content bounds; opening it dims + covers the content
// below with a scrim and the dialog's own ColumnLayout. `open()`/`close()`
// control visibility; Esc or an explicit dismiss() closes it.
//
// The WindowDialogTitle / WindowDialogSeparator / WindowDialogButtonRow
// helpers are separate widget files so vendored dialog content (VolumeDialog
// content, WifiDialog, ...) can reference them like ii.
Item {
    id: root

    property bool show: false
    property int backgroundHeight: 0
    default property alias content: host.data

    // Closes the dialog. Called by the Done button, a scrim click, or Esc.
    // (Kept as a function, not a signal, so callers see the side effect of
    // actually hiding the dialog regardless of Connections inheritance quirks.)
    function dismiss() { root.show = false }

    function open() { root.show = true }
    function close() { root.show = false }

    visible: root.show
    anchors.fill: parent
    z: 9999

    // Scrim: dim + block interaction with the underlying content.
    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Color.menu.scrim
        opacity: root.show ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
        MouseArea {
            anchors.fill: parent
            onClicked: root.dismiss()
        }
    }

    // Dialog surface.
    Rectangle {
        id: surface
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 8
        }
        color: Color.popups.background
        border.color: Color.popups.border
        border.width: 1
        radius: 12
        clip: true

        // Slide/move-up from the bottom edge so it feels like ii's overlay.
        visible: root.show
        y: root.show ? 0 : parent.height
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        ColumnLayout {
            id: host
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
        }
    }

    onVisibleChanged: if (root.show) forceActiveFocus()
    Keys.onPressed: event => { if (event.key === Qt.Key_Escape) root.dismiss() }
    focus: root.show
}
