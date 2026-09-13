import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../../"
import "../../services"
import "../../stubs"
import "../../widgets"

// Vendored from ii's .../volumeMixer/VolumeDialogContent.qml -- per-app
// volume sliders (Audio.outputAppNodes/inputAppNodes) plus a default-device
// picker (Audio.outputDevices/inputDevices), for whichever direction the
// parent VolumeDialog is showing.
//
// Simplified vs. upstream: ii's StyledComboBox/PagePlaceholder/MaterialShape
// widgets weren't ported (out of scope for this mixer -- not used by anything
// else in this plugin), so the device picker is a plain QtQuick.Controls
// ComboBox and the empty state is a plain centered label instead of an
// iconed placeholder. Behavior is otherwise the same.
ColumnLayout {
    id: root
    required property bool isSink
    readonly property list<var> appPwNodes: isSink ? Audio.outputAppNodes : Audio.inputAppNodes
    readonly property list<var> devices: isSink ? Audio.outputDevices : Audio.inputDevices
    readonly property bool hasApps: appPwNodes.length > 0
    spacing: 16

    StyledListView {
        id: appListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        topMargin: 12
        bottomMargin: 12
        clip: true
        spacing: 4
        animateAppearance: false

        model: ScriptModel {
            values: root.appPwNodes
        }
        delegate: VolumeMixerEntry {
            required property var modelData
            node: modelData
            width: ListView.view.width
        }

        StyledText {
            anchors.centerIn: parent
            visible: !root.hasApps
            text: Translation.tr("No applications")
            color: Appearance.colors.colSubtext
        }
    }

    ComboBox {
        id: deviceSelector
        Layout.fillWidth: true
        Layout.bottomMargin: 6
        model: root.devices.map(node => Audio.friendlyDeviceName(node))
        currentIndex: root.devices.findIndex(item => {
            if (root.isSink) {
                return item.id === Pipewire.defaultAudioSink?.id;
            } else {
                return item.id === Pipewire.defaultAudioSource?.id;
            }
        })
        onActivated: (index) => {
            const item = root.devices[index];
            if (root.isSink) {
                Audio.setDefaultSink(item);
            } else {
                Audio.setDefaultSource(item);
            }
        }
    }
}
