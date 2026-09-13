pragma Singleton
import QtQuick
import Quickshell

// Minimal stand-in for illogical-impulse's Directories.qml (XDG dirs +
// shell-specific paths). Only exposes what the vendored Persistent/Todo
// closure reads: a state directory and the to-do list's JSON file path --
// pointed at THIS PLUGIN's own state dir
// (~/.local/state/omarchy/trevor.ii-control-center/), not wherever a real
// separate ii install on this machine would write, so the two never clash.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME") || ""
    readonly property string state: `${Quickshell.env("XDG_STATE_HOME") || (root.home + "/.local/state")}/omarchy/trevor.ii-control-center`
    readonly property string todoPath: `${root.state}/todo.json`

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.state])
}
