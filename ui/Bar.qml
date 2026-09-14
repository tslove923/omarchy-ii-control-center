import QtQuick
import Quickshell
import qs.Ui
import qs.Commons
import "ii-common/stubs"

// Far-right bar icon for the ii Control Center. Clicking it toggles the
// `overlay`-kind entry point (ui/ControlCenter.qml) via the same
// `omarchy shell shell toggle <id> '{}'` CLI path first-party plugins use
// (see com.omastorm.radar's RadarBar.qml `expand()` for precedent) --
// bar-widget and overlay/panel entry points are separate host-managed
// surfaces, there's no direct QML reference between them.
BarWidget {
  id: root
  moduleName: "trevor.ii-control-center"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function toggle() {
    Quickshell.execDetached(["omarchy", "shell", "shell", "toggle", "trevor.ii-control-center", "{}"])
  }
  // Hover-to-open uses summon, not toggle: toggle would close an
  // already-open panel on a hover that lands right after a click, which
  // isn't what "hover opens it" should ever do. summon() is idempotent
  // while already open (see shell.qml's deliverIfLoaded -- a repeat call
  // just redelivers the payload), so re-triggering it on every hover is
  // harmless.
  function summon() {
    Quickshell.execDetached(["omarchy", "shell", "shell", "summon", "trevor.ii-control-center", "{}"])
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: 27
    opticalSize: 16
    useActiveColor: false
    iconComponent: Component {
      Image {
        anchors.centerIn: parent
        source: "assets/illogical-impulse.svg"
        sourceSize.width: 16
        sourceSize.height: 16
        smooth: true
      }
    }
    onPressed: b => { if (b === Qt.LeftButton) root.toggle() }

    // tooltipHovered is WidgetButton's own containsMouse-derived property
    // (BarIconButton's base) -- functionally "is this button hovered"
    // despite the tooltip-oriented name, so it's reused here rather than
    // laying a second MouseArea over one that already owns press handling.
    // Debounced open-only, matching the hover-preview pattern used in the
    // sibling trevor.ii-mpris-indicator plugin: a short delay so a mouse
    // just passing over the icon doesn't flash the whole sidebar open.
    onTooltipHoveredChanged: {
      if (tooltipHovered && Config.options.sidebar.hoverToOpen) hoverOpenTimer.restart()
      else hoverOpenTimer.stop()
    }
  }

  Timer {
    id: hoverOpenTimer
    interval: 400
    onTriggered: root.summon()
  }
}
