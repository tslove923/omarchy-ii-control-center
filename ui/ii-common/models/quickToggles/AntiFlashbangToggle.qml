import QtQuick
import "../../services"
import "../../"
import "../../stubs"

// Ported from ii's .../models/quickToggles/AntiFlashbangToggle.qml. ii binds
// to its HyprlandAntiFlashbangShader service; this plugin's equivalent is the
// ii-common/services/AntiFlashbang.qml shim (same enabled/weak/cycle surface,
// direct hyprctl screen_shader calls, shaders vendored into
// ui/assets/hyprlandAntiFlashbangShader/). Only the service name differs.
QuickToggleModel {
    name: AntiFlashbang.enabled ? (AntiFlashbang.weak ? Translation.tr("Anti-flash: Weak") : Translation.tr("Anti-flash: Strong")) : Translation.tr("Anti-flashbang")
    tooltipText: `${Translation.tr("Anti-flashbang")}: ${AntiFlashbang.enabled ? (AntiFlashbang.weak ? Translation.tr("Weak") : Translation.tr("Strong")) : Translation.tr("Off")}`
    icon: AntiFlashbang.enabled ? (!AntiFlashbang.weak ? "flash_off" : "sunny_snowing") : "flash_on"
    toggled: AntiFlashbang.enabled

    mainAction: () => {
        AntiFlashbang.cycle()
    }
    hasMenu: true

    Component.onCompleted: AntiFlashbang.fetchState()
}
