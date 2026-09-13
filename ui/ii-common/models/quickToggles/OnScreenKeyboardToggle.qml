import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/OnScreenKeyboardToggle.qml. ii's
// real one toggles its own in-shell QML on-screen-keyboard panel; Omarchy has
// no equivalent OSK surface a plugin can drive, so per the port's note-gaps
// rule this tile ships but is marked unavailable (rendered disabled in the
// grid) rather than wired to a mismatched action.
QuickToggleModel {
    name: Translation.tr("Virtual Keyboard")
    available: false
    toggled: false
    icon: "keyboard"

    mainAction: () => { /* no Omarchy OSK backend -- intentionally inert */ }

    tooltipText: Translation.tr("On-screen keyboard (unavailable on Omarchy)")
}
