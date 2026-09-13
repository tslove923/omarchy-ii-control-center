import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/DarkModeToggle.qml. ii flips its
// wallpaper switch script between --mode light/dark (a per-shell palette
// swap). Omarchy applies whole named themes with no light-only/dark-only
// toggle, so per the port's note-gaps rule this action opens Omarchy's theme
// switcher instead of pretending to toggle a dark/light bit. Appearance
// reflects the static m3 palette, which this plugin ships dark-only.
QuickToggleModel {
    name: Translation.tr("Dark Mode")
    statusText: Appearance.m3colors.darkmode ? Translation.tr("Dark") : Translation.tr("Light")

    toggled: Appearance.m3colors.darkmode
    icon: "contrast"
    
    mainAction: () => {
        // Omarchy themes carry their own light/dark look; open the picker so
        // the user can choose a dark theme, rather than a no-op toggle.
        Quickshell.execDetached(["omarchy", "theme", "switcher"])
    }

    tooltipText: Translation.tr("Dark Mode (opens Omarchy theme switcher)")
}
