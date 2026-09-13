import QtQuick
import Quickshell
import "../../services"
import "../../"
import "../../stubs"

// Vendored from ii's .../models/quickToggles/NightLightToggle.qml -- import
// paths re-pointed at this plugin's vendored Hyprsunset service (real
// hyprctl-hyprsunset calls).
QuickToggleModel {
    property bool auto: Config.options.light.night.automatic

    name: Translation.tr("Night Light")
    statusText: (auto ? Translation.tr("Auto, ") : "") + (toggled ? Translation.tr("Active") : Translation.tr("Inactive"))

    toggled: Hyprsunset.temperatureActive
    icon: auto ? "night_sight_auto" : "bedtime"
    
    mainAction: () => {
        Hyprsunset.toggleTemperature()
    }
    hasMenu: true

    Component.onCompleted: {
        Hyprsunset.fetchState()
    }
    
    tooltipText: Translation.tr("Night Light | Right-click to configure")
}
