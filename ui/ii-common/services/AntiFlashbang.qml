pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Not a verbatim vendor: ii's real HyprlandAntiFlashbangShader.qml reads/
// writes through a `HyprlandConfig`/`HyprlandConfigOption` abstraction
// (modules/common/models/hyprland/, itself several hundred lines wrapping
// `hyprctl keyword`/`hyprctl getoption` with change-batching) that nothing
// else in this port needs. Ported the same way this plugin's own
// classicStyle/GameMode.qml already does its Hyprland toggle: direct
// `hyprctl keyword`/`hyprctl getoption -j` calls -- functionally identical,
// just without the extra abstraction layer.
//
// The two GLSL shaders themselves (dim-the-screen-by-average-brightness) are
// vendored verbatim from ii's services/hyprlandAntiFlashbangShader/ into
// this plugin's ui/assets/hyprlandAntiFlashbangShader/.
Singleton {
    id: root

    readonly property string pluginUiDir: Qt.resolvedUrl("../../").toString().replace("file://", "")
    readonly property string weakShaderPath: `${root.pluginUiDir}assets/hyprlandAntiFlashbangShader/anti-flashbang-weak.glsl`
    readonly property string strongShaderPath: `${root.pluginUiDir}assets/hyprlandAntiFlashbangShader/anti-flashbang.glsl`

    property bool enabled: false
    property bool weak: false

    function enableWeak() {
        Quickshell.execDetached(["bash", "-c", `hyprctl --batch "keyword decoration:screen_shader ${root.weakShaderPath} ; keyword debug:damage_tracking 1"`]);
        root.enabled = true;
        root.weak = true;
    }

    function enableStrong() {
        Quickshell.execDetached(["bash", "-c", `hyprctl --batch "keyword decoration:screen_shader ${root.strongShaderPath} ; keyword debug:damage_tracking 1"`]);
        root.enabled = true;
        root.weak = false;
    }

    function disable() {
        // Mirrors classicStyle/GameMode.qml's own reset approach: a config
        // reload restores whatever hyprland.conf itself says for these two
        // keywords (unset, in the common case).
        Quickshell.execDetached(["hyprctl", "reload"]);
        root.enabled = false;
        root.weak = false;
    }

    function cycle() {
        if (!root.enabled) root.enableWeak();
        else if (root.weak) root.enableStrong();
        else root.disable();
    }

    function fetchState() {
        fetchStateProc.running = true;
    }

    Component.onCompleted: root.fetchState()

    Process {
        id: fetchStateProc
        command: ["bash", "-c", "hyprctl getoption decoration:screen_shader -j | jq -r .str"]
        stdout: StdioCollector {
            id: shaderCollector
            onStreamFinished: {
                const current = shaderCollector.text.trim();
                root.enabled = (current === root.weakShaderPath || current === root.strongShaderPath);
                root.weak = (current === root.weakShaderPath);
            }
        }
    }
}
