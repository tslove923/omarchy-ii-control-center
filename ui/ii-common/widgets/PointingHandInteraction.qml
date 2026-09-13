import QtQuick

// Vendored verbatim from ii's modules/common/widgets/PointingHandInteraction.qml.
MouseArea {
    anchors.fill: parent
    onPressed: (mouse) => mouse.accepted = false
    cursorShape: Qt.PointingHandCursor
}
