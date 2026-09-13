pragma Singleton
import "../stubs"
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Shim for ii's services/Audio.qml. Started as sink/source/toggleMute/
// toggleMicMute for the QuickSliders/AudioToggle/MicToggle consumers; extended
// here (ported near-verbatim from reference-ii/services/Audio.qml) with the
// node-classification helpers and lists the volume-mixer submenu needs.
// Deliberately DROPPED from the real ii service: the Config-coupled
// audio-protection volume limiter (Connections block guarding against sudden
// volume jumps) and playSystemSound (ffplay .oga/.ogg theme sounds) -- neither
// is needed for a mixer/device-picker and both pull in Config surface this
// plugin's stub doesn't model.
Singleton {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Mute toggles for the AudioToggle/MicToggle quick-toggle models. The
    // Pipewire sink/source nodes expose a mutable `audio.muted`, so toggling
    // is a direct property write (no pactl round-trip).
    function toggleMute() {
        const s = root.sink?.audio;
        if (s) s.muted = !s.muted;
    }
    function toggleMicMute() {
        const s = root.source?.audio;
        if (s) s.muted = !s.muted;
    }

    // Display-name helpers used by the volume mixer entries / device selector.
    function friendlyDeviceName(node) {
        return (node?.nickname || node?.description || Translation.tr("Unknown"));
    }
    function appNodeDisplayName(node) {
        return (node?.properties?.["application.name"] || node?.description || node?.name);
    }

    // Node classification: sink/source *device* nodes (speakers, mics, ...)
    // vs. per-application client *stream* nodes (what's actually playing/
    // recording audio right now) -- same split Omarchy's own audio panel
    // draws via candidateSinks, just expressed against PwNode.isSink/isStream.
    function correctType(node, isSink) {
        return (node.isSink === isSink) && node.audio;
    }
    function appNodes(isSink) {
        return Pipewire.nodes.values.filter((node) => { // Should be list<PwNode> but it breaks ScriptModel
            return root.correctType(node, isSink) && node.isStream;
        });
    }
    function devices(isSink) {
        return Pipewire.nodes.values.filter((node) => {
            return root.correctType(node, isSink) && !node.isStream;
        });
    }
    readonly property list<var> outputAppNodes: root.appNodes(true)
    readonly property list<var> inputAppNodes: root.appNodes(false)
    readonly property list<var> outputDevices: root.devices(true)
    readonly property list<var> inputDevices: root.devices(false)

    // Default device switching, used by the mixer's device-selector combo box.
    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }
    function setDefaultSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
