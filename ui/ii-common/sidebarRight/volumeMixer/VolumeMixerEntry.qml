import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../"
import "../../services"
import "../../stubs"
import "../../widgets"

// Vendored from ii's .../volumeMixer/VolumeMixerEntry.qml -- one row in the
// volume mixer: mute button, app/media name, and a volume slider, for one
// Pipewire app stream node.
//
// Simplified vs. upstream: drops the per-app icon (StyledImage +
// Qt5Compat.GraphicalEffects Desaturate) since AppSearch is stubbed to never
// resolve an icon here anyway (see services/AppSearch.qml) -- the mute-state
// glyph (volume_off/mic_off) still shows over the button when muted, same as
// upstream.
Item {
    id: root
    required property PwNode node
    PwObjectTracker {
        objects: [root.node]
    }

    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 6

        MouseArea {
            property real size: 36
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth: size
            Layout.preferredHeight: size

            cursorShape: Qt.PointingHandCursor
            onClicked: root.node.audio.muted = !root.node.audio.muted

            hoverEnabled: true
            property bool hovered: containsMouse
            StyledToolTip {
                text: root.node?.audio.muted ? Translation.tr("Click to unmute") : Translation.tr("Click to mute")
            }

            Rectangle {
                anchors.fill: parent
                radius: Appearance.rounding.full
                color: Appearance.colors.colLayer2
                visible: parent.hovered
            }

            MaterialSymbol {
                anchors.centerIn: parent
                iconSize: 22
                color: Appearance.colors.colOnLayer1
                text: root.node?.audio.muted ? (root.node?.isSink ? "volume_off" : "mic_off") : (root.node?.isSink ? "volume_up" : "mic")
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: -4

            StyledText {
                Layout.fillWidth: true
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colSubtext
                elide: Text.ElideRight
                text: {
                    // application.name -> description -> name
                    const app = Audio.appNodeDisplayName(root.node);
                    const media = root.node.properties["media.name"];
                    return media != undefined ? `${app} • ${media}` : app;
                }
            }

            StyledSlider {
                id: slider
                value: root.node?.audio.volume ?? 0
                onMoved: root.node.audio.volume = value
                configuration: StyledSlider.Configuration.S
            }
        }
    }
}
