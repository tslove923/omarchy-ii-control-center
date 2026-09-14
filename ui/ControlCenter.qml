import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import "ii-common"
import "ii-common/stubs"
import "ii-common/widgets"
import "ii-common/sidebarRight"
import "ii-common/sidebarRight/quickToggles"
import "ii-common/sidebarRight/wifiNetworks"
import "ii-common/sidebarRight/bluetoothDevices"
import "ii-common/sidebarRight/volumeMixer"

// ii Control Center overlay. Anchored top+bottom+right (left deliberately
// omitted) is the standard wlr-layer-shell idiom for a full-height,
// right-docked sidebar -- this is what makes it behave like ii's real
// `sidebarRight` (a full-height PanelWindow) rather than a small
// bar-anchored popout bubble, which is what Omarchy's `panel` kind gives you
// (see omarchy.osd / omarchy.dev-gallery: plain content-sized Items with no
// window/anchor control of their own). `overlay` kind is the one Omarchy
// surface where the plugin owns real WlrLayershell geometry.
//
// The content below is the REAL illogical-impulse sidebarRight QML, vendored
// into ui/ii-common/ and instantiated here basically as ii itself would.
// QuickSliders.qml is ii's slider row verbatim; AndroidQuickPanel.qml is ii's
// Android-style quick-toggle grid (the user's chosen style -- see the Config
// stub, which defaults `quickToggles.style` to "android") backed by ii's
// QuickToggleModel objects ported into ii-common/models/quickToggles/.
// Backend wiring is done via thin shim singletons under ii-common/services/
// as with the rest of the port.
//
// Right-click / secondary actions: in real ii each toggle's "menu" pops a
// modal WindowDialog (volume mixer / bluetooth devices / wifi list / night
// light slider). That popup stack is part of ii's own `qs` module and isn't a
// Quickshell builtin, so per the port's "use Omarchy equivalents, note gaps"
// rule the menu actions here open the equivalent native/Omarchy UIs instead
// (nm-connection-editor / blueman-manager / pavucontrol / omarchy nightlight)
// -- see handleOpen*Dialog below. The toggles themselves (their main
// on/off action) are all real and unchanged.
Item {
  id: root

  property bool opened: false
  property bool editMode: false
  function open(payloadJson) { opened = true }
  // Closing this outer panel must not leave an inner WindowDialog (wifi /
  // bluetooth / volume) "logically open" just because the panel's own
  // window went invisible out from under it -- an inner dialog Item's own
  // `visible` binding (visible: root.show) never changes on its own here,
  // so its onVisibleChanged side effects (e.g. BluetoothDialog stopping
  // Bluetooth discovery) would never fire. This was the confirmed root
  // cause of discovery being left running indefinitely: this close() is
  // called by the bar icon/keybind toggle AND by the blow-off-some-steam
  // auto-close, and previously only ever touched `opened`. Explicitly
  // dismiss any loaded dialog first so its own dismiss()/onVisibleChanged
  // path runs normally.
  function close() {
    if (wifiDialogLoader.item) wifiDialogLoader.item.dismiss()
    if (bluetoothDialogLoader.item) bluetoothDialogLoader.item.dismiss()
    if (audioDialogLoader.item) audioDialogLoader.item.dismiss()
    opened = false
  }

  visible: opened

  // --- blow-off-some-steam interaction fix ---
  // That plugin's Arena is a PanelWindow at the same WlrLayer.Overlay layer
  // as this one (WlrLayershell.namespace: "blow-off-some-steam"). It works
  // by grim-capturing a frozen screenshot of the desktop and letting the
  // player destroy that static texture. If this panel is open when the
  // capture happens, the panel's pixels get baked into the frozen texture --
  // but the real, still-open panel keeps compositing on top of it
  // regardless, un-shootable and unaffected no matter what happens to the
  // frozen copy underneath.
  //
  // There's no documented IPC between the two plugins for this (that
  // plugin's only IpcHandler is generic open/close; Omarchy's shell IPC has
  // no "is plugin X open" query), so there's no clean way to synchronize
  // precisely with the exact moment grim fires inside the other plugin.
  // Instead, poll Hyprland's own compositor state (`hyprctl -j layers`,
  // which lists every mapped layer-shell surface's namespace) while this
  // panel is open, and close it as soon as that plugin's Arena surface
  // appears -- the same close() the bar widget/keybind already use.
  //
  // Honest limitation: this gets the panel out of the way promptly once the
  // game starts (fixing "it just floats there immune the whole time the
  // game is open"), but it does NOT guarantee this panel's own pixels end
  // up baked into the destructible frozen texture -- that would require
  // matching the exact instant grim fires inside that plugin, which briefly
  // unmaps/remaps its own Arena surface around the capture specifically so
  // the transition hides that preparation time (see the "unmapped before
  // screencopy" comment in its Arena.qml). That instant isn't observable
  // from outside without cooperation from that plugin, so this is a
  // detect-and-get-out-of-the-way fix, not a guaranteed-part-of-the-rubble
  // fix.
  Timer {
    id: gameWatchTimer
    interval: 450
    repeat: true
    running: root.opened
    onTriggered: {
      if (!gameCheckProcess.running)
        gameCheckProcess.running = true
    }
  }

  Process {
    id: gameCheckProcess
    running: false
    command: ["hyprctl", "-j", "layers"]
    stdout: StdioCollector {
      onStreamFinished: root.checkForBlowOffSomeSteam(this.text)
    }
  }

  function checkForBlowOffSomeSteam(layersJson) {
    try {
      const outputs = JSON.parse(layersJson || "{}");
      for (const outputName in outputs) {
        const levels = outputs[outputName]?.levels ?? {};
        for (const levelKey in levels) {
          const surfaces = levels[levelKey] ?? [];
          for (const surf of surfaces) {
            if (surf?.namespace === "blow-off-some-steam") {
              root.close();
              return;
            }
          }
        }
      }
    } catch (e) {
      // Malformed/empty hyprctl output -- ignore this tick, try again next.
    }
  }

  PanelWindow {
    id: window
    visible: root.opened
    // Anchored to all four edges (full screen) now, not just top+bottom+
    // right -- needed so the window itself can receive a click anywhere
    // outside the actual sidebar card, for closeOnOutsideClick below.
    // Everything left of the card is genuinely transparent + (when the
    // setting is on) a click-catcher, not visually part of the panel;
    // the card itself still only occupies cardWidth on the right, same
    // as before.
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    // 380 clipped BottomWidgetGroup's calendar tab: the nav rail (56px) +
    // its 10px left margin + row spacing (20px) + the calendar's own
    // natural width (7 columns * 38px day cells + 6 * 5px gaps = 296px)
    // need at least 382px inside the panel's own 32px (2*16) horizontal
    // margin -- 428px total minimum. 440 leaves a little breathing room.
    property int cardWidth: 440

    WlrLayershell.namespace: "ii-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    // Not Exclusive: a docked sidebar shouldn't steal keyboard focus from
    // whatever's focused underneath just by being open (matches ii's own
    // sidebarRight, which is click/hover driven, not modal).
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // Click-outside-to-close. Only covers the region left of the card --
    // a plain MouseArea with no visible content, consuming (not
    // forwarding) the one click that lands on it, same idiom
    // omarchy.clipboard's own full-screen overlay uses for its click-away
    // dismiss. Gated on the config default-on setting; when off, this
    // region is otherwise fully inert (no MouseArea at all), so anything
    // behind the panel is unaffected either way -- it was never
    // click-through before this change and isn't meant to become so now.
    MouseArea {
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: card.left
      }
      enabled: Config.options.sidebar.closeOnOutsideClick
      onClicked: root.close()
    }

    Rectangle {
      id: card
      anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
      width: window.cardWidth
      color: Color.popups.background
      border.color: Color.popups.border
      border.width: 1

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentCol.implicitHeight + Style.space(32)

        Column {
          id: contentCol
          width: parent.width - Style.space(32)
          anchors {
            top: parent.top
            topMargin: Style.space(16)
            left: parent.left
            leftMargin: Style.space(16)
          }
          spacing: Style.space(16)

          // Header: logo + title, then edit-mode + close buttons
          RowLayout {
            id: headerRow
            width: parent.width
            spacing: Style.space(8)

            Image {
              source: "assets/illogical-impulse.svg"
              sourceSize.width: 20
              sourceSize.height: 20
              Layout.alignment: Qt.AlignVCenter
            }
            Text {
              text: "Control Center"
              textFormat: Text.PlainText
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.heading
              Layout.alignment: Qt.AlignVCenter
            }
            Item { Layout.fillWidth: true }
            Rectangle {
              id: editModeButton
              width: 30
              height: 30
              radius: 8
              color: root.editMode ? Color.accent : Color.popups.background
              border.color: Color.popups.border
              border.width: 1
              Layout.alignment: Qt.AlignVCenter
              MouseArea {
                anchors.fill: parent
                onClicked: root.editMode = !root.editMode
                cursorShape: Qt.PointingHandCursor
              }
              MaterialSymbol {
                anchors.centerIn: parent
                text: "edit"
                iconSize: 16
                fill: root.editMode ? 1 : 0
                color: root.editMode ? Color.background : Color.popups.text
              }
              StyledToolTip { extraVisibleCondition: true; text: "Edit quick toggles" }
            }
          }

          // Real ii QuickSliders.qml: brightness/night-light-gamma, volume,
          // mic -- Material Symbol icons riding the slider fill.
          QuickSliders {
            width: parent.width
          }

          // Real ii AndroidQuickPanel.qml: the Android quick-toggle grid --
          // network/bluetooth/idle/nightlight/darkmode/warp/gamemode/etc.,
          // each backed by a real ported QuickToggleModel. Edit mode
          // (add/remove/resize/reorder) is toggled from the header button.
          AndroidQuickPanel {
            width: parent.width
            editMode: root.editMode
            onOpenWifiDialog: root.handleOpenWifiDialog()
            onOpenBluetoothDialog: root.handleOpenBluetoothDialog()
            onOpenAudioOutputDialog: root.handleOpenAudioDialog(true)
            onOpenAudioInputDialog: root.handleOpenAudioDialog(false)
            onOpenNightLightDialog: root.handleOpenNightLightDialog()
          }

          // Real ii WorldClocks.qml: a few timezones, sorted by offset from
          // local time (updates every 15s + on day change).
          WorldClocks {
            width: parent.width
          }

          // Real ii BottomWidgetGroup.qml: collapsible Calendar / To Do
          // tabs with a nav rail. Backed by the vendored CalendarWidget /
          // TodoWidget + the Todo/DateTime services.
          BottomWidgetGroup {
            width: parent.width
          }
        }
      }

      // In-shell configure submenus (ii ports) overlay the panel content.
      // NOTE: WindowDialog.dismiss() is a plain function (it sets its own
      // `show` false directly) rather than a signal, so these watch
      // item.show itself -- via its own visible binding (visible: root.show) and Item.visibleChanged -- to drop
      // the Loader's `active` flag once the dialog closes itself (Done
      // button / scrim click / Esc), instead of a Connections{ onDismiss }
      // handler (which needs an actual `dismiss` signal to fire on).
      Loader {
        id: wifiDialogLoader
        anchors.fill: parent
        z: 9999
        active: root.showWifiDialog
        onLoaded: item.show = true
        sourceComponent: WifiDialog {}
        Connections {
          target: item
          function onVisibleChanged() { if (!item.visible) root.showWifiDialog = false }
        }
      }
      Loader {
        id: bluetoothDialogLoader
        anchors.fill: parent
        z: 10000
        active: root.showBluetoothDialog
        onLoaded: item.show = true
        sourceComponent: BluetoothDialog {}
        Connections {
          target: item
          function onVisibleChanged() { if (!item.visible) root.showBluetoothDialog = false }
        }
      }
      Loader {
        id: audioDialogLoader
        anchors.fill: parent
        z: 10001
        active: root.showAudioDialog
        onLoaded: item.show = true
        sourceComponent: VolumeDialog { isSink: root.audioDialogIsSink }
        Connections {
          target: item
          function onVisibleChanged() { if (!item.visible) root.showAudioDialog = false }
        }
      }
    }
  }

  // --- Menu ("configure") actions, re-pointed at Omarchy/native equivalents. ---
  function handleOpenWifiDialog() {
    root.showWifiDialog = true
  }
  function handleOpenBluetoothDialog() {
    root.showBluetoothDialog = true
  }
  function handleOpenAudioDialog(isSink) {
    root.audioDialogIsSink = isSink
    root.showAudioDialog = true
  }
  function handleOpenNightLightDialog() {
    // Adjust night-light warmth via Omarchy's canonical toggle/OSD.
    Quickshell.execDetached(["omarchy", "toggle", "nightlight"])
  }

  property bool showWifiDialog: false
  property bool showBluetoothDialog: false
  property bool showAudioDialog: false
  property bool audioDialogIsSink: true
}
