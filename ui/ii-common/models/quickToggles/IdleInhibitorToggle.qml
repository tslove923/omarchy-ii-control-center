import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"
import "../../widgets"

// Ported from ii's .../models/quickToggles/IdleInhibitorToggle.qml -- the
// plugin's Idle service implements the same real Wayland idle-inhibitor
// mechanism (Quickshell.Wayland IdleInhibit) that ii's service does, so the
// model is a verbatim drop-in modulo imports.
QuickToggleModel {
    name: Translation.tr("Keep awake")

    toggled: Idle.inhibit
    icon: "coffee"
    mainAction: () => {
        Idle.toggleInhibit()
    }
    tooltipText: Translation.tr("Keep system awake")
}
