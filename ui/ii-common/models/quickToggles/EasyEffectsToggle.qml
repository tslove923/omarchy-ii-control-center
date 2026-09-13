import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/EasyEffectsToggle.qml -- import
// paths re-pointed at this plugin's vendored EasyEffects service. Backend is
// real (the service probes/launches the `easyeffects` binary / flatpak), so
// this is a verbatim drop-in.
QuickToggleModel {
    name: Translation.tr("EasyEffects")

    available: EasyEffects.available
    toggled: EasyEffects.active
    icon: "graphic_eq"

    Component.onCompleted: {
        EasyEffects.fetchActiveState()
    }

    mainAction: () => {
        EasyEffects.toggle()
    }

    altAction: () => {
        Quickshell.execDetached(["bash", "-c", "flatpak run com.github.wwmm.easyeffects || easyeffects"])
        GlobalStates.sidebarRightOpen = false
    }

    tooltipText: Translation.tr("EasyEffects | Right-click to configure")
}
