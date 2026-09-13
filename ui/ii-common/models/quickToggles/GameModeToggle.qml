import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/GameModeToggle.qml. ii drives this
// through its HyprlandConfig.setMany/resetMany abstraction; the plugin has no
// such helper (classicStyle deliberately dropped GameMode), so the same
// Hyprland keyword toggling is done with direct `hyprctl --batch` calls --
// the identical technique the plugin's own AntiFlashbang service uses. The
// user's pre-game-mode values are read once at load (via `hyprctl getoption`
// <key> -j`) so "reset" restores their real config rather than hardcoded
// defaults.
QuickToggleModel {
    id: root
    name: Translation.tr("Game mode")
    toggled: !animationsEnabled
    icon: "gamepad"

    property bool animationsEnabled: true
    property int gapsIn: 8
    property int gapsOut: 8
    property int borderSize: 2
    property int rounding: 17

    mainAction: () => {
        root.toggled = !root.toggled;
        if (root.toggled) {
            Quickshell.execDetached(["hyprctl", "--batch",
                "keyword animations:enabled 0 ; keyword decoration:shadow:enabled 0 ; keyword decoration:blur:enabled 0 ; keyword general:gaps_in 0 ; keyword general:gaps_out 0 ; keyword general:border_size 1 ; keyword decoration:rounding 0 ; keyword general:allow_tearing 1"]);
        } else {
            Quickshell.execDetached(["bash", "-c",
                `hyprctl --batch "keyword animations:enabled 1 ; keyword decoration:shadow:enabled 1 ; keyword decoration:blur:enabled 1 ; keyword general:gaps_in ${root.gapsIn} ; keyword general:gaps_out ${root.gapsOut} ; keyword general:border_size ${root.borderSize} ; keyword decoration:rounding ${root.rounding} ; keyword general:allow_tearing 0"`]);
        }
    }

    Component.onCompleted: {
        fetchGapsIn.running = true;
        fetchGapsOut.running = true;
        fetchBorderSize.running = true;
        fetchRounding.running = true;
        fetchAnimations.running = true;
    }

    function intFromJson(collectorText, fallback) {
        try {
            const v = JSON.parse(collectorText)?.int ?? null;
            return (v === null) ? fallback : v;
        } catch (e) {
            return fallback;
        }
    }
    function boolFromJson(collectorText, fallback) {
        try {
            const v = JSON.parse(collectorText)?.value ?? null;
            return (v === null) ? fallback : !!v;
        } catch (e) {
            return fallback;
        }
    }

    Process { id: fetchGapsIn; running: false; command: ["bash", "-c", "hyprctl getoption general:gaps_in -j"]; stdout: StdioCollector { onStreamFinished: root.gapsIn = root.intFromJson(this.text, root.gapsIn) } }
    Process { id: fetchGapsOut; running: false; command: ["bash", "-c", "hyprctl getoption general:gaps_out -j"]; stdout: StdioCollector { onStreamFinished: root.gapsOut = root.intFromJson(this.text, root.gapsOut) } }
    Process { id: fetchBorderSize; running: false; command: ["bash", "-c", "hyprctl getoption general:border_size -j"]; stdout: StdioCollector { onStreamFinished: root.borderSize = root.intFromJson(this.text, root.borderSize) } }
    Process { id: fetchRounding; running: false; command: ["bash", "-c", "hyprctl getoption decoration:rounding -j"]; stdout: StdioCollector { onStreamFinished: root.rounding = root.intFromJson(this.text, root.rounding) } }
    Process { id: fetchAnimations; running: false; command: ["bash", "-c", "hyprctl getoption animations:enabled -j"]; stdout: StdioCollector { onStreamFinished: root.animationsEnabled = root.boolFromJson(this.text, root.animationsEnabled) } }

    tooltipText: Translation.tr("Game mode")
}
