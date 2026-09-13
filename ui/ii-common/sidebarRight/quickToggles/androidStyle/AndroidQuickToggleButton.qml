import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../"
import "../../../stubs"
import "../../../models/quickToggles"
import "../../../functions"
import "../../../widgets"

// Vendored from ii's .../androidStyle/AndroidQuickToggleButton.qml -- import
// paths re-pointed at this plugin's vendored ii-common tree (services,
// Appearance/Config/Translation shims, models/quickToggles, ColorUtils,
// widgets). The button is the cell that renders a QuickToggleModel's
// state/actions in the Android grid, including its edit-mode (add/remove/
// resize/reorder) interactions, which mutate the user-editable toggle layout
// persisted by the Config stub's android-toggles.json.
GroupButton {
    id: root
    
    // Info to be passed to by repeater
    required property int buttonIndex
    required property var buttonData
    required property bool expandedSize
    required property real baseCellWidth
    required property real baseCellHeight
    required property real cellSpacing
    required property int cellSize

    // Signals
    signal openMenu()

    // Declared in specific toggles
    property QuickToggleModel toggleModel
    property string name: toggleModel?.name ?? ""
    property string statusText: (toggleModel?.hasStatusText) ? (toggleModel?.statusText || (toggled ? Translation.tr("On") : Translation.tr("Off"))) : ""
    property string tooltipText: toggleModel?.tooltipText ?? ""
    property string buttonIcon: toggleModel?.icon ?? "close"
    property bool available: toggleModel?.available ?? true
    toggled: toggleModel?.toggled ?? false
    property var mainAction: toggleModel?.mainAction ?? null
    altAction: toggleModel?.hasMenu ? (() => root.openMenu()) : (toggleModel?.altAction ?? null)

    // Edit mode state
    property bool editMode: false

    // Sizing shenanigans
    baseWidth: root.baseCellWidth * cellSize + cellSpacing * (cellSize - 1)
    baseHeight: root.baseCellHeight
    enableImplicitWidthAnimation: !editMode && root.mouseArea.containsMouse
    enableImplicitHeightAnimation: !editMode && root.mouseArea.containsMouse
    Behavior on baseWidth {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    Behavior on baseHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    opacity: 0
    Component.onCompleted: {
        opacity = 1
    }
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    enabled: available || editMode
    padding: 6
    horizontalPadding: padding
    verticalPadding: padding

    colBackground: Appearance.colors.colLayer2
    colBackgroundToggled: (altAction && expandedSize) ? Appearance.colors.colLayer2 : Appearance.colors.colPrimary
    colBackgroundToggledHover: (altAction && expandedSize) ? Appearance.colors.colLayer2Hover : Appearance.colors.colPrimaryHover
    colBackgroundToggledActive: (altAction && expandedSize) ? Appearance.colors.colLayer2Active : Appearance.colors.colPrimaryActive
    buttonRadius: toggled ? Appearance.rounding.large : height / 2
    buttonRadiusPressed: Appearance.rounding.normal
    property color colText: (toggled && !(altAction && expandedSize) && enabled) ? Appearance.colors.colOnPrimary : ColorUtils.transparentize(Appearance.colors.colOnLayer2, enabled ? 0 : 0.7)
    property color colIcon: expandedSize ? ((root.toggled) ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer3) : colText

    onClicked: {
        if (root.expandedSize && root.altAction) root.altAction();
        else root.mainAction();
    }

    contentItem: RowLayout {
        id: contentItem
        spacing: 4
        anchors {
            centerIn: root.expandedSize ? undefined : parent
            fill: root.expandedSize ? parent : undefined
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }

        // Icon
        MouseArea {
            id: iconMouseArea
            hoverEnabled: true
            acceptedButtons: (root.expandedSize && root.altAction) ? Qt.LeftButton : Qt.NoButton
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.topMargin: root.verticalPadding
            Layout.bottomMargin: root.verticalPadding
            implicitHeight: iconBackground.implicitHeight
            implicitWidth: iconBackground.implicitWidth
            cursorShape: Qt.PointingHandCursor

            onClicked: root.mainAction()

            Rectangle {
                id: iconBackground
                anchors.fill: parent
                implicitWidth: height
                radius: root.radius - root.verticalPadding
                color: {
                    const baseColor = root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colLayer3
                    const transparentizeAmount = (root.altAction && root.expandedSize) ? 0 : 1
                    return ColorUtils.transparentize(baseColor, transparentizeAmount)
                }

                Behavior on radius {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: root.toggled ? 1 : 0
                    iconSize: root.expandedSize ? 22 : 24
                    color: root.colIcon
                    text: root.buttonIcon
                }

                // State layer
                Loader {
                    anchors.fill: parent
                    active: (root.expandedSize && root.altAction)
                    sourceComponent: Rectangle {
                        radius: iconBackground.radius
                        color: ColorUtils.transparentize(root.colIcon, iconMouseArea.containsPress ? 0.88 : iconMouseArea.containsMouse ? 0.95 : 1)
                        Behavior on color {
                            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }
                }
            }
        }

        // Text column for expanded size
        Loader {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            visible: root.expandedSize
            active: visible
            sourceComponent: Column {
                spacing: -2

                StyledText {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    font.pixelSize: Appearance.font.pixelSize.smallie
                    font.weight: 600
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.name
                }

                StyledText {
                    visible: root.statusText
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    font {
                        pixelSize: Appearance.font.pixelSize.smaller
                        weight: 100
                    }
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.statusText
                }
            }
        }
    }

    // Drop-target highlight, shown on every OTHER used tile while a drag
    // from elsewhere in the grid is hovering over this one.
    Rectangle {
        anchors.fill: parent
        visible: root.isDropTarget
        radius: root.buttonRadius
        color: "transparent"
        border.width: 2
        border.color: Appearance.colors.colPrimary
        z: 10
    }

    // Whether another tile is currently being dragged over this one. Only
    // used (already-persisted) tiles participate as drag sources or targets;
    // unused tiles (buttonIndex < 0, in the "add a toggle" tray) keep their
    // plain tap-to-add behavior below.
    readonly property bool isDropTarget: root.editMode && root.buttonIndex >= 0
        && DragState.sourceType !== "" && DragState.sourceType !== root.buttonData.type
        && (function() {
            const p = root.mapFromGlobal(DragState.globalX, DragState.globalY);
            return p.x >= 0 && p.x < root.width && p.y >= 0 && p.y < root.height;
        })()
    onIsDropTargetChanged: {
        if (root.isDropTarget) DragState.hoverType = root.buttonData.type;
        else if (DragState.hoverType === root.buttonData.type) DragState.hoverType = "";
    }

    MouseArea { // Blocking MouseArea for edit interactions
        id: editModeInteraction
        visible: root.editMode
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons

        property bool dragging: false
        property real pressX: 0
        property real pressY: 0
        readonly property real dragThreshold: 8

        // All three mutate a *copy* of the persisted array and reassign it
        // back to Config (rather than push()/splice()-ing the array in
        // place), and resolve the entry to change by toggle type rather than
        // by this delegate's row-relative buttonIndex. In-place mutation
        // doesn't fire QML's property-changed notification, so the grid
        // (and the on-disk android-toggles.json) silently went stale after
        // an edit; a positional index also doesn't reliably identify the
        // same entry once rows have wrapped or a previous edit shifted
        // things around, which could add/remove/resize the wrong tile.
        function toggleEnabled() {
            const buttonType = root.buttonData.type;
            const list = Config.options.sidebar.quickToggles.android.toggles.slice();
            const idx = list.findIndex(t => t && t.type === buttonType);
            if (idx === -1) {
                list.push({ type: buttonType, size: 1 });
            } else {
                list.splice(idx, 1);
            }
            Config.options.sidebar.quickToggles.android.toggles = list;
        }

        function toggleSize() {
            const buttonType = root.buttonData.type;
            const list = Config.options.sidebar.quickToggles.android.toggles.slice();
            const idx = list.findIndex(t => t && t.type === buttonType);
            if (idx === -1) return;
            list[idx] = { type: list[idx].type, size: 3 - list[idx].size }; // Alternate between 1 and 2
            Config.options.sidebar.quickToggles.android.toggles = list;
        }

        // Real drag-and-drop reorder: swaps this tile's persisted position
        // with otherType's.
        function swapWithType(otherType) {
            const buttonType = root.buttonData.type;
            const list = Config.options.sidebar.quickToggles.android.toggles.slice();
            const idxA = list.findIndex(t => t && t.type === buttonType);
            const idxB = list.findIndex(t => t && t.type === otherType);
            if (idxA === -1 || idxB === -1 || idxA === idxB) return;
            const tmp = list[idxA];
            list[idxA] = list[idxB];
            list[idxB] = tmp;
            Config.options.sidebar.quickToggles.android.toggles = list;
        }

        onPressed: (event) => {
            if (event.button === Qt.LeftButton) {
                editModeInteraction.dragging = false;
                editModeInteraction.pressX = event.x;
                editModeInteraction.pressY = event.y;
            } else if (event.button === Qt.RightButton) {
                toggleSize();
            }
        }
        onPositionChanged: (event) => {
            if (!(event.buttons & Qt.LeftButton) || root.buttonIndex < 0) return;
            if (!editModeInteraction.dragging) {
                const dx = event.x - editModeInteraction.pressX;
                const dy = event.y - editModeInteraction.pressY;
                if (Math.sqrt(dx * dx + dy * dy) < editModeInteraction.dragThreshold) return;
                editModeInteraction.dragging = true;
                const gp = editModeInteraction.mapToGlobal(event.x, event.y);
                DragState.begin(root.buttonData.type, root.buttonIcon, gp.x, gp.y);
            } else {
                const gp = editModeInteraction.mapToGlobal(event.x, event.y);
                DragState.move(gp.x, gp.y);
            }
        }
        onReleased: (event) => {
            if (event.button !== Qt.LeftButton) return;
            if (editModeInteraction.dragging) {
                const targetType = DragState.hoverType;
                DragState.end();
                editModeInteraction.dragging = false;
                if (targetType && targetType !== root.buttonData.type) {
                    editModeInteraction.swapWithType(targetType);
                }
            } else {
                toggleEnabled();
            }
        }
        onCanceled: {
            DragState.end();
            editModeInteraction.dragging = false;
        }
        onPressAndHold: (event) => { // Also toggle size
            if (!editModeInteraction.dragging) toggleSize();
        }
    }

    StyledToolTip {
        extraVisibleCondition: root.tooltipText !== ""
        text: root.tooltipText
    }
}
