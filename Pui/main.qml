import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    width: 1920
    height: 1080
    visible: true
    title: "Player UI"
    color: "#120F13"

    FontLoader {
        id: pixelFont
        source: "fonts/8bitoperator_jve.ttf"
    }

    property int maxVisibleCards: 48
    property int baseCardWidth: 450
    property int baseCardHeight: 180
    property int fixedColumnGap: 20
    property int fixedRowGap: 16
    property int visibleCombatants: Math.min(grid.count, maxVisibleCards)
    property var cardLayoutByCount: ({
        1: { columns: 1, rows: 1, scale: 1.00 },
        2: { columns: 2, rows: 1, scale: 1.00 },
        3: { columns: 3, rows: 1, scale: 1.00 },
        4: { columns: 3, rows: 2, scale: 1.00 },
        5: { columns: 3, rows: 2, scale: 1.00 },
        6: { columns: 3, rows: 2, scale: 1.00 },
        7: { columns: 3, rows: 3, scale: 1.00 },
        8: { columns: 3, rows: 3, scale: 1.00 },
        9: { columns: 3, rows: 3, scale: 1.00 },
        10: { columns: 3, rows: 4, scale: 1.00 },
        11: { columns: 3, rows: 4, scale: 0.67 },
        12: { columns: 3, rows: 4, scale: 0.67 },
        13: { columns: 3, rows: 5, scale: 0.67 },
        14: { columns: 3, rows: 5, scale: 0.67 },
        15: { columns: 3, rows: 5, scale: 0.67 },
        16: { columns: 4, rows: 4, scale: 0.67 },
        17: { columns: 4, rows: 5, scale: 0.67 },
        18: { columns: 4, rows: 5, scale: 0.67 },
        19: { columns: 4, rows: 5, scale: 0.67 },
        20: { columns: 4, rows: 5, scale: 0.67 },
        21: { columns: 4, rows: 6, scale: 0.55 },
        22: { columns: 4, rows: 6, scale: 0.55 },
        23: { columns: 4, rows: 6, scale: 0.55 },
        24: { columns: 4, rows: 6, scale: 0.55 },
        25: { columns: 4, rows: 7, scale: 0.55 },
        26: { columns: 4, rows: 7, scale: 0.55 },
        27: { columns: 5, rows: 6, scale: 0.55 },
        28: { columns: 5, rows: 6, scale: 0.55 },
        29: { columns: 5, rows: 6, scale: 0.55 },
        30: { columns: 5, rows: 6, scale: 0.55 },
        31: { columns: 5, rows: 7, scale: 0.48 },
        32: { columns: 5, rows: 7, scale: 0.48 },
        33: { columns: 5, rows: 7, scale: 0.48 },
        34: { columns: 5, rows: 7, scale: 0.48 },
        35: { columns: 5, rows: 7, scale: 0.48 },
        36: { columns: 5, rows: 8, scale: 0.48 },
        37: { columns: 5, rows: 8, scale: 0.48 },
        38: { columns: 5, rows: 8, scale: 0.48 },
        39: { columns: 6, rows: 7, scale: 0.48 },
        40: { columns: 6, rows: 7, scale: 0.48 },
        41: { columns: 6, rows: 7, scale: 0.42 },
        42: { columns: 6, rows: 7, scale: 0.42 },
        43: { columns: 6, rows: 8, scale: 0.42 },
        44: { columns: 6, rows: 8, scale: 0.42 },
        45: { columns: 6, rows: 8, scale: 0.42 },
        46: { columns: 6, rows: 8, scale: 0.42 },
        47: { columns: 6, rows: 8, scale: 0.42 },
        48: { columns: 6, rows: 8, scale: 0.42 },
        49: { columns: 6, rows: 9, scale: 0.42 },
        50: { columns: 6, rows: 9, scale: 0.42 }
    })
    property var activeLayout: cardLayoutByCount[visibleCombatants] || cardLayoutByCount[48]
    property real dynamicCardScale: visibleCombatants > 0 ? activeLayout.scale : 1.0
    property int dynamicColumns: visibleCombatants > 0 ? activeLayout.columns : 1
    property int dynamicRows: visibleCombatants > 0 ? activeLayout.rows : 1
    property int dynamicCardWidth: Math.round(baseCardWidth * dynamicCardScale)
    property int dynamicCardHeight: Math.round(baseCardHeight * dynamicCardScale)
    property color inkLight: "#F1E4D1"
    property color inkMuted: "#C9B7A0"
    property color inkSoft: "#9A8672"
    property color panelDark: "#19131A"
    property color panelMid: "#241B22"
    property color panelEdge: "#5F4A3C"
    property color accentWarm: "#D6763F"
    property color accentBright: "#E0B26B"
    property color accentCool: "#4AA7FF"
    property color accentViolet: "#7A63D8"
    property color accentSmoke: "#140F13"
    property color accentTemp: "#63BEFF"
    property color accentPoison: "#9DFF2D"
    property color hpFillColor: "#73CD76"
    property color damageFillColor: "#D6493E"
    property color barBackground: "#100D12"
    property real heartbeatPhase: 0

    NumberAnimation on heartbeatPhase {
        from: 0
        to: Math.PI * 2
        duration: 1200
        loops: Animation.Infinite
        running: true
    }

    Rectangle {
        anchors.fill: parent
        z: -2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0E0A10" }
            GradientStop { position: 0.55; color: "#1A1318" }
            GradientStop { position: 1.0; color: "#0F0B11" }
        }
    }

    Image {
        anchors.fill: parent
        source: "textures/back.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        opacity: 0.18
        z: -1
    }

    Column {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10
        padding: 20

        Rectangle {
            id: headerPanel
            width: Math.min(parent.width - 40, parent.width * 0.92)
            anchors.horizontalCenter: parent.horizontalCenter
            height: 112
            radius: 0
            color: "#2B2028"
            border.width: 1
            border.color: panelEdge

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                Item {
                    Layout.preferredWidth: headerPanel.width * 0.30
                    Layout.fillHeight: true

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        spacing: 2

                        Text {
                            text: "Раунд "
                            color: inkLight
                            font.pixelSize: 34
                            font.family: pixelFont.name
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: playerState ? playerState.round : 0
                            color: accentBright
                            font.pixelSize: 36
                            font.family: pixelFont.name
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.preferredWidth: headerPanel.width * 0.60
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    color: "#1A141C"
                    border.width: 1
                    border.color: "#3B2D35"
                    radius: 0

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2

                        Repeater {
                            model: playerState ? playerState.logLines : ["", "", ""]

                            Rectangle {
                                width: parent.width
                                height: (parent.height - 4) / 3
                                color: "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - 8
                                    text: modelData
                                    color: inkLight
                                    textFormat: Text.RichText
                                    font.pixelSize: 27
                                    font.family: pixelFont.name
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    wrapMode: Text.NoWrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id: battlefieldArea
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Column {
            anchors.fill: parent

            Item {
                width: parent.width
                height: parent.height

                GridView {
                    id: grid
                    width: dynamicColumns * cellWidth
                    height: dynamicRows * cellHeight
                    anchors.centerIn: parent
                    model: playerModel
                    cellWidth: dynamicCardWidth + fixedColumnGap
                    cellHeight: dynamicCardHeight + fixedRowGap
                    flow: GridView.FlowLeftToRight
                    layoutDirection: Qt.LeftToRight
                    interactive: false
                    clip: true
                    delegate: Rectangle {
                id: card
                width: dynamicCardWidth
                height: dynamicCardHeight
                visible: index < maxVisibleCards
                radius: 0
            color: panelMid
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#2E2229" }
                GradientStop { position: 1.0; color: "#1E161D" }
            }
            border.width: 1
            border.color: panelEdge
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 6
                anchors.leftMargin: 2
                anchors.rightMargin: -2
                anchors.bottomMargin: -6
                radius: 0
                color: "#3D000000"
                z: -1
            }
            property real baseScale: 0.9
            property real cardUiScale: Math.max(0.42, width / root.baseCardWidth)
            property real activeScaleBoost: is_active ? 1.03 : 1.0
            scale: baseScale * incapacitatedScaleFactor * leftScaleFactor * activeScaleBoost
            transformOrigin: Item.Center
            opacity: 1.0

            property bool isPlayer: kind === "player" || (hp === null && max_hp === null)
            property bool isMonster: kind === "monster" || (hp !== null && max_hp !== null)
            property bool showHpText: !isPlayer && !isMonster
            property bool showHpBar: !isPlayer
            property string displayName: {
                var baseName = display_name ? display_name : name
                if (isMonster && baseName) {
                    return baseName.replace(/\s*\d+$/, "")
                }
                return baseName
            }
            property var hpValue: hp
            property real hpRatio: (max_hp && hp !== null) ? Math.max(0, Math.min(1, hp / max_hp)) : 0
            property real displayedHpRatio: hpRatio
            property real pendingDamageHpRatio: hpRatio
            property real pendingHealHpRatio: hpRatio
            property real lastHpRatio: hpRatio
            property var lastHp: hpValue
            property color flashColor: "transparent"
            property real flashPeak: 0.35
            property real shakeOffset: 0
            property real liftOffset: 0
            property real statusDim: 0
            property real leftGrayDim: 0.0
            property real leftCardOpacity: 1.0
            property color statusFlashColor: "transparent"
            property real statusFlashPeak: 0.4
            property bool isActive: is_active
            property string stateValue: model.state ? model.state : "alive"
            property int tempHpValue: temp_hp
            property string lastState: stateValue
            property var lastTempHp: tempHpValue
            property var effectList: {
                var list = []
                if (effects) {
                    if (effects.list && effects.list.length) {
                        list = effects.list.slice(0)
                    } else {
                        if (effects.incapacitated) list.push("Недеесп.")
                    }
                    if (effects.other && effects.other.length) {
                        list = list.concat(effects.other)
                    }
                }
                return list
            }
            property int customEffectSlots: root.visibleCombatants <= 10 ? 4 : (root.visibleCombatants <= 20 ? 2 : (root.visibleCombatants <= 30 ? 1 : 0))
            property int customEffectColumns: customEffectSlots === 4 ? 2 : 1
            property var customEffectSourceList: {
                var list = []
                if (custom_effects) {
                    if (custom_effects.list && custom_effects.list.length) {
                        list = custom_effects.list.slice(0)
                    } else {
                        for (var customName in custom_effects) {
                            if (custom_effects[customName]) {
                                list.push(customName)
                            }
                        }
                    }
                }
                if (list.length === 0) {
                    list = effectList.slice(0)
                }
                return list
            }
            property var customEffectList: {
                var list = []
                for (var i = 0; i < customEffectSourceList.length; ++i) {
                    var effectName = customEffectSourceList[i]
                    if (!effectName || !effectName.trim || effectName.trim().length === 0) {
                        continue
                    }
                    var lowerName = effectName.toLowerCase()
                    var isAnimatedEffect = lowerName.indexOf("конц") === 0
                        || lowerName.indexOf("временн") === 0
                        || lowerName.indexOf("недеесп") === 0
                    if (!isAnimatedEffect) {
                        list.push(effectName)
                    }
                }
                return list
            }
            property var displayCustomEffects: {
                if (customEffectSlots <= 0) {
                    return []
                }
                var list = []
                for (var i = 0; i < customEffectSlots; ++i) {
                    list.push("")
                }
                var filledCount = Math.min(customEffectList.length, customEffectSlots)
                for (var j = 0; j < filledCount; ++j) {
                    list[j] = customEffectList[j]
                }
                if (customEffectList.length > customEffectSlots && customEffectSlots > 0) {
                    list[customEffectSlots - 1] = "…"
                }
                return list
            }
            property bool concentrationActive: effects && effects.concentration
            property bool lastConcentration: concentrationActive
            property int concentrationFrameIndex: 0
            property int concentrationFrameDirection: 1
            property bool concentrationVisualActive: false
            property string concentrationPrimarySource: ""
            property string concentrationSecondarySource: ""
            property var concentrationFrames: [
                "textures/conc1.png",
                "textures/conc2.png",
                "textures/conc3.png"
            ]
            property int concentrationFrameWidth: 1179
            property int concentrationFrameHeight: 694
            property int concentrationCanvasWidth: 1536
            property int concentrationCanvasHeight: 1024
            property real overlayScaleX: concentrationCanvasWidth / concentrationFrameWidth
            property real overlayScaleY: concentrationCanvasHeight / concentrationFrameHeight
            property int tempHpFrameWidth: 1290
            property int tempHpFrameHeight: 526
            property real tempHpScaleAdjustX: 1.018
            property real tempHpScaleAdjustY: 1.008
            property real tempHpScaleX: (concentrationCanvasWidth / tempHpFrameWidth) * tempHpScaleAdjustX
            property real tempHpScaleY: (concentrationCanvasHeight / tempHpFrameHeight) * tempHpScaleAdjustY
            property int tempHpFrameIndex: 0
            property int tempHpFrameDirection: 1
            property bool tempHpVisualActive: false
            property string tempHpPrimarySource: ""
            property string tempHpSecondarySource: ""
            property var tempHpFrames: [
                "textures/temphp1.png",
                "textures/temphp2.png",
                "textures/temphp3.png"
            ]
            property bool concentrationTempActive: concentrationActive && tempHpValue > 0
            property bool turnOverlayActive: isActive && stateValue === "alive"
            property int concentrationTempTargetFrameWidth: concentrationFrameWidth
            property int concentrationTempTargetFrameHeight: concentrationFrameHeight
            property var concentrationTempFrameWidths: [1187, 1152, 1173]
            property var concentrationTempFrameHeights: [547, 510, 492]
            property int concentrationTempFrameIndex: 0
            property int concentrationTempFrameDirection: 1
            property bool concentrationTempVisualActive: false
            property int concentrationTempPrimaryFrameMetaIndex: 0
            property int concentrationTempSecondaryFrameMetaIndex: 0
            property string concentrationTempPrimarySource: ""
            property string concentrationTempSecondarySource: ""
            property var concentrationTempFrames: [
                "textures/conctemp1.png",
                "textures/conctemp2.png",
                "textures/conctemp3.png"
            ]
            property bool useAlternateConcentrationTempFrame: false
            property real concentrationTempPrimaryTargetOpacity: 1.0
            property real concentrationTempSecondaryTargetOpacity: 0.0
            property bool useAlternateFrame: false
            property real primaryTargetOpacity: 1.0
            property real secondaryTargetOpacity: 0.0
            property bool useAlternateTempHpFrame: false
            property real tempHpPrimaryTargetOpacity: 1.0
            property real tempHpSecondaryTargetOpacity: 0.0
            property int turnFrameIndex: 0
            property int turnFrameDirection: 1
            property bool turnVisualActive: false
            property string turnVisualKey: ""
            property string pendingTurnVisualKey: ""
            property string turnPrimarySource: ""
            property string turnSecondarySource: ""
            property bool useAlternateTurnFrame: false
            property real turnPrimaryTargetOpacity: 1.0
            property real turnSecondaryTargetOpacity: 0.0
            property var activeTurnFrames: [
                "textures/turn1.png",
                "textures/turn2.png",
                "textures/turn2.png"
            ]
            property var turnConcentrationFrames: [
                "textures/turnconc1.png",
                "textures/turnconc2.png",
                "textures/turnconc2.png"
            ]
            property var turnTempHpFrames: [
                "textures/turntemphp1.png",
                "textures/turntemphp2.png",
                "textures/turntemphp2.png"
            ]
            property var turnConcentrationTempFrames: [
                "textures/turnconctemphp1.png",
                "textures/turnconctemphp2.png",
                "textures/turnconctemphp2.png"
            ]
            property real overlayHeightScale: 1.15
            property bool incapacitatedActive: effects && effects.incapacitated
            property bool incapacitatedEligible: incapacitatedActive && stateValue === "alive"
            property bool tempIncapActive: incapacitatedEligible && tempHpValue > 0
            property bool lastIncapacitated: incapacitatedActive
            property bool lastTempIncapActive: tempIncapActive
            property real incapacitatedOpacity: incapacitatedEligible ? 1 : 0
            property real incapacitatedDim: 0.0
            property real deathDim: 0.0
            property real incapacitatedScaleFactor: 1.0
            property real leftScaleFactor: 1.0
            property int incapacitatedFrameIndex: -1
            property string incapacitatedFrameSource: ""
            property var incapacitatedFrames: [
                "textures/incap1.png",
                "textures/incap2.png",
                "textures/incap3.png",
                "textures/incap4.png",
                "textures/incap5.png"
            ]
            property var incapacitatedFrameSizes: [
                { width: 1337, height: 585 },
                { width: 1337, height: 585 },
                { width: 1337, height: 585 },
                { width: 1337, height: 585 },
                { width: 1277, height: 512 }
            ]
            property int activeIncapacitatedFrameWidth: (
                incapacitatedFrameIndex >= 0 && incapacitatedFrameIndex < incapacitatedFrameSizes.length
                    ? incapacitatedFrameSizes[incapacitatedFrameIndex].width
                    : incapacitatedFrameSizes[0].width
            )
            property int activeIncapacitatedFrameHeight: (
                incapacitatedFrameIndex >= 0 && incapacitatedFrameIndex < incapacitatedFrameSizes.length
                    ? incapacitatedFrameSizes[incapacitatedFrameIndex].height
                    : incapacitatedFrameSizes[0].height
            )
            property int incapacitatedCanvasWidth: 1536
            property int incapacitatedCanvasHeight: 1024
            property real incapacitatedScaleX: incapacitatedCanvasWidth / activeIncapacitatedFrameWidth
            property real incapacitatedScaleY: incapacitatedCanvasHeight / activeIncapacitatedFrameHeight
            property real incapacitatedShrinkPx: 4
            property real incapacitatedShrinkScale: width > 0 ? (width - incapacitatedShrinkPx * 2) / width : 1.0
            property int tempIncapFrameIndex: -1
            property string tempIncapPrimarySource: ""
            property int tempIncapFrameWidth: 1140
            property int tempIncapFrameHeight: 415
            property int tempIncapCanvasWidth: 1536
            property int tempIncapCanvasHeight: 1024
            property real tempIncapScaleX: tempIncapCanvasWidth / tempIncapFrameWidth
            property real tempIncapScaleY: tempIncapCanvasHeight / tempIncapFrameHeight
            property var tempIncapFrames: [
                "textures/tempincap1.png",
                "textures/tempincap2.png",
                "textures/tempincap3.png",
                "textures/tempincap4.png",
                "textures/tempincap5it1.png"
            ]
            property int deathFrameIndex: -1
            property string deathFrameSource: ""
            property var deathFrames: [
                "textures/death1.png",
                "textures/death2.png",
                "textures/death3.png",
                "textures/death4.png",
                "textures/death5.png"
            ]
            property var deathFrameOpaqueRects: [
                { x: 33, y: 64, width: 1491, height: 840 },
                { x: 27, y: 55, width: 1486, height: 871 },
                { x: 26, y: 54, width: 1493, height: 873 },
                { x: 26, y: 54, width: 1492, height: 873 },
                { x: 26, y: 55, width: 1493, height: 872 }
            ]
            property var activeDeathFrameOpaqueRect: (
                deathFrameIndex >= 0 && deathFrameIndex < deathFrameOpaqueRects.length
                    ? deathFrameOpaqueRects[deathFrameIndex]
                    : deathFrameOpaqueRects[0]
            )
            // Fast tuning controls for death texture fitting
            property real deathFitScaleX: 1.354
            property real deathFitScaleY: 1.863
            property real deathOverlayOffsetX: 0
            property real deathOverlayOffsetY: 0
            property int leftTavernFrameIndex: -1
            property string leftTavernFrameSource: ""
            property var leftTavernFrames: [
                "textures/tavern1.png",
                "textures/tavern2.png",
                "textures/tavern3.png"
            ]
            property var leftTavernFrameOpaqueRects: [
                { x: 26, y: 55, width: 1493, height: 872 },
                { x: 26, y: 55, width: 1493, height: 872 },
                { x: 26, y: 55, width: 1493, height: 872 }
            ]
            property var activeLeftTavernOpaqueRect: (
                leftTavernFrameIndex >= 0 && leftTavernFrameIndex < leftTavernFrameOpaqueRects.length
                    ? leftTavernFrameOpaqueRects[leftTavernFrameIndex]
                    : leftTavernFrameOpaqueRects[0]
            )
            property real leftTavernFitScaleX: 1.0
            property real leftTavernFitScaleY: 1.0
            property real leftTavernForcedScaleX: width > 0 ? (width + 10) / width : 1.0
            property real leftTavernForcedScaleY: height > 0 ? (height + 10) / height : 1.0
            property real leftTavernScaleBoostX: 1.176
            property real leftTavernScaleBoostY: 2.0592
            property real leftWantedScale: 0.759
            property int leftWantedFrameIndex: -1
            property string leftWantedFrameSource: ""
            property var leftWantedFrames: [
                "textures/wanted1.png",
                "textures/wanted2.png"
            ]
            property string pendingStateVisual: ""
            property bool suppressIncapacitatedReverseAfterLeft: false
            property real overlayInset: 0
            property int damageFrameIndex: -1
            property string damageFrameSource: ""
            property var damageFrames: [
                "textures/dmg1.png",
                "textures/dmg2.png",
                "textures/dmg3.png",
                "textures/dmg4.png",
                "textures/dmg5.png"
            ]
            property int healFrameIndex: -1
            property string healFrameSource: ""
            property var healFrames: [
                "textures/heal1.png",
                "textures/heal2.png",
                "textures/heal3.png",
                "textures/heal4.png",
                "textures/heal5.png"
            ]

            function startDamageSequence(targetRatio) {
                if (healFrameTimer.running) {
                    healFrameTimer.stop()
                    healFrameIndex = -1
                    healFrameSource = ""
                }
                pendingDamageHpRatio = targetRatio
                damageFrameIndex = 0
                damageFrameSource = damageFrames[0]
                damageFrameTimer.restart()
                damageShakeAnim.restart()
            }

            function startHealSequence(targetRatio) {
                if (damageFrameTimer.running) {
                    damageFrameTimer.stop()
                    damageFrameIndex = -1
                    damageFrameSource = ""
                }
                pendingHealHpRatio = targetRatio
                healFrameIndex = 0
                healFrameSource = healFrames[0]
                healFrameTimer.restart()
                healShakeAnim.restart()
            }

            function applyStateVisuals(nextState) {
                if (nextState === "dead") {
                    statusFlashColor = damageFillColor
                    statusFlashPeak = 0.45
                    statusFlashAnim.restart()
                    statusDim = 0.9
                } else if (nextState === "unconscious") {
                    statusFlashColor = damageFillColor
                    statusFlashPeak = 0.32
                    statusFlashAnim.restart()
                    statusDim = 0.55
                } else if (nextState === "left") {
                    statusDim = 0
                } else if (nextState === "alive") {
                    if (lastState === "dead" || lastState === "unconscious") {
                        statusFlashColor = accentBright
                        statusFlashPeak = 0.4
                        statusFlashAnim.restart()
                        liftAnim.restart()
                    }
                    statusDim = 0
                }
            }

            function setIncapacitatedFrame(index) {
                incapacitatedFrameIndex = index
                var nextSource = (index >= 0 && index < incapacitatedFrames.length) ? incapacitatedFrames[index] : ""
                if (incapacitatedFrameSource !== nextSource) {
                    incapacitatedFrameSource = nextSource
                }
            }

            function setTempIncapFrame(index) {
                tempIncapFrameIndex = index
                var source = (index >= 0 && index < tempIncapFrames.length) ? tempIncapFrames[index] : ""
                if (tempIncapPrimarySource !== source) {
                    tempIncapPrimarySource = source
                }
                if (tempIncapFramePrimary) {
                    tempIncapFramePrimary.opacity = 1.0
                }
            }

            function stopIncapacitatedAnimations() {
                incapacitatedForward.stop()
                incapacitatedReverse.stop()
            }

            function setDeathFrame(index) {
                deathFrameIndex = index
                var nextSource = (index >= 0 && index < deathFrames.length) ? deathFrames[index] : ""
                if (deathFrameSource !== nextSource) {
                    deathFrameSource = nextSource
                }
            }

            function setLeftTavernFrame(index) {
                leftTavernFrameIndex = index
                var nextSource = (index >= 0 && index < leftTavernFrames.length) ? leftTavernFrames[index] : ""
                if (leftTavernFrameSource !== nextSource) {
                    leftTavernFrameSource = nextSource
                }
            }

            function setLeftWantedFrame(index) {
                leftWantedFrameIndex = index
                var nextSource = (index >= 0 && index < leftWantedFrames.length) ? leftWantedFrames[index] : ""
                if (leftWantedFrameSource !== nextSource) {
                    leftWantedFrameSource = nextSource
                }
            }

            function stopDeathAnimations() {
                deathForward.stop()
            }

            function stopLeftAnimations() {
                leftBattleForward.stop()
                leftBattleReverse.stop()
            }

            function startDeathForward() {
                clearIncapacitatedVisuals()
                stopDeathAnimations()
                deathDim = 0.0
                incapacitatedScaleFactor = 1.0
                setDeathFrame(0)
                deathForward.restart()
            }

            function clearDeathVisuals() {
                stopDeathAnimations()
                setDeathFrame(-1)
                deathDim = 0.0
                incapacitatedScaleFactor = 1.0
            }

            function startLeftForward() {
                clearIncapacitatedVisuals()
                clearDeathVisuals()
                stopLeftAnimations()
                leftGrayDim = 0.0
                leftCardOpacity = 1.0
                leftScaleFactor = 1.0
                setLeftTavernFrame(0)
                setLeftWantedFrame(-1)
                leftBattleForward.restart()
            }


            function startLeftReverse() {
                stopLeftAnimations()
                if (leftTavernFrameIndex < 0) {
                    setLeftTavernFrame(2)
                }
                if (leftWantedFrameIndex < 0) {
                    setLeftWantedFrame(1)
                }
                leftBattleReverse.restart()
            }

            function clearLeftVisuals() {
                stopLeftAnimations()
                setLeftTavernFrame(-1)
                setLeftWantedFrame(-1)
                leftGrayDim = 0.0
                leftCardOpacity = 1.0
                leftScaleFactor = 1.0
            }

            function clearIncapacitatedVisuals() {
                stopTempIncapAnimations()
                stopIncapacitatedAnimations()
                setTempIncapFrame(-1)
                setIncapacitatedFrame(-1)
                incapacitatedDim = 0.0
            }

            function stopTempIncapAnimations() {
                tempIncapForward.stop()
                tempIncapReverse.stop()
            }

            function startIncapacitatedForward() {
                if (stateValue !== "alive") {
                    return
                }
                stopIncapacitatedAnimations()
                incapacitatedDim = 0.0
                incapacitatedScaleFactor = 1.0
                setIncapacitatedFrame(0)
                incapacitatedForward.restart()
            }

            function startIncapacitatedReverse() {
                if (stateValue !== "alive") {
                    return
                }
                stopIncapacitatedAnimations()
                if (incapacitatedFrameIndex < 0) {
                    setIncapacitatedFrame(4)
                }
                incapacitatedReverse.restart()
            }

            function startTempIncapForward() {
                if (stateValue !== "alive") {
                    return
                }
                stopTempIncapAnimations()
                stopIncapacitatedAnimations()
                setIncapacitatedFrame(-1)
                incapacitatedDim = 0.0
                incapacitatedScaleFactor = 1.0
                setTempIncapFrame(0)
                tempIncapForward.restart()
            }

            function startTempIncapReverse() {
                if (stateValue !== "alive") {
                    return
                }
                stopTempIncapAnimations()
                stopIncapacitatedAnimations()
                setIncapacitatedFrame(-1)
                if (tempIncapFrameIndex < 0) {
                    setTempIncapFrame(4)
                }
                tempIncapReverse.restart()
            }

            function turnVisualFramesForKey(key) {
                if (key === "conctemp") return turnConcentrationTempFrames
                if (key === "conc") return turnConcentrationFrames
                if (key === "temphp") return turnTempHpFrames
                if (key === "turn") return activeTurnFrames
                return []
            }

            function desiredTurnVisualKey() {
                if (!turnOverlayActive) return ""
                if (concentrationActive && tempHpValue > 0) return "conctemp"
                if (concentrationActive) return "conc"
                if (tempHpValue > 0) return "temphp"
                return "turn"
            }

            function refreshTurnVisual() {
                var nextKey = desiredTurnVisualKey()
                if (!nextKey) {
                    pendingTurnVisualKey = ""
                    if (turnVisualActive) {
                        turnFrameDirection = -1
                        turnFrameIndex = 2
                        turnTimer.restart()
                    }
                    return
                }

                if (!turnVisualActive) {
                    var startFrames = turnVisualFramesForKey(nextKey)
                    turnVisualActive = true
                    turnVisualKey = nextKey
                    turnFrameDirection = 1
                    turnFrameIndex = 0
                    useAlternateTurnFrame = false
                    turnFramePrimary.opacity = 1.0
                    turnFrameSecondary.opacity = 0.0
                    turnPrimarySource = startFrames[0]
                    turnSecondarySource = startFrames[0]
                    turnTimer.restart()
                    return
                }

                if (turnVisualKey !== nextKey) {
                    pendingTurnVisualKey = nextKey
                    turnFrameDirection = -1
                    turnFrameIndex = 2
                    turnTimer.restart()
                    return
                }

                var replayFrames = turnVisualFramesForKey(nextKey)
                turnFrameDirection = 1
                turnFrameIndex = 0
                useAlternateTurnFrame = false
                turnFramePrimary.opacity = 1.0
                turnFrameSecondary.opacity = 0.0
                turnPrimarySource = replayFrames[0]
                turnSecondarySource = replayFrames[0]
                turnTimer.restart()
            }

            transform: [
                Translate { x: shakeOffset; y: liftOffset }
            ]

            Rectangle {
                id: statusBar
                height: Math.max(24, Math.round(36 * cardUiScale))
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                radius: 0
                color: "#32252D"
                border.width: 1
                border.color: isActive ? "#FFF4AE" : panelEdge
                z: 4
                opacity: leftCardOpacity
                gradient: Gradient {
                    GradientStop { position: 0.0; color: isActive ? "#FFFCE9" : "#3A2C35" }
                    GradientStop { position: 1.0; color: isActive ? "#FFD45A" : "#32252D" }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: isActive ? "#FFF4AE" : panelEdge
                }

                Text {
                    anchors.centerIn: parent
                    text: isActive ? "Ходит" : (stateValue === "dead" ? "Мертв" : stateValue === "unconscious" ? "Без сознания" : stateValue === "left" ? "Покинул бой" : "Жив")
                    color: isActive ? "#111111" : inkLight
                    font.pixelSize: Math.max(12, Math.round(19 * cardUiScale))
                    font.family: pixelFont.name
                }
            }

            Behavior on activeScaleBoost {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }

            Rectangle {
                id: flashOverlay
                anchors.fill: parent
                radius: 0
                color: flashColor
                opacity: 0.0
                visible: opacity > 0
            }

            Rectangle {
                id: statusFlash
                anchors.fill: parent
                radius: 0
                color: statusFlashColor
                opacity: 0.0
                visible: opacity > 0
            }

            SequentialAnimation {
                id: flashAnim
                running: false
                PropertyAnimation {
                    target: flashOverlay
                    property: "opacity"
                    from: 0.0
                    to: flashPeak
                    duration: 120
                    easing.type: Easing.OutQuad
                }
                PropertyAnimation {
                    target: flashOverlay
                    property: "opacity"
                    to: 0.0
                    duration: 320
                    easing.type: Easing.OutQuad
                }
            }

            SequentialAnimation {
                id: statusFlashAnim
                running: false
                PropertyAnimation {
                    target: statusFlash
                    property: "opacity"
                    from: 0.0
                    to: statusFlashPeak
                    duration: 140
                    easing.type: Easing.OutQuad
                }
                PropertyAnimation {
                    target: statusFlash
                    property: "opacity"
                    to: 0.0
                    duration: 420
                    easing.type: Easing.OutQuad
                }
            }

            SequentialAnimation {
                id: shakeAnim
                running: false
                NumberAnimation { target: card; property: "shakeOffset"; from: 0; to: -6; duration: 40; easing.type: Easing.OutQuad }
                NumberAnimation { target: card; property: "shakeOffset"; from: -6; to: 6; duration: 60; easing.type: Easing.InOutQuad }
                NumberAnimation { target: card; property: "shakeOffset"; from: 6; to: -4; duration: 60; easing.type: Easing.InOutQuad }
                NumberAnimation { target: card; property: "shakeOffset"; from: -4; to: 0; duration: 80; easing.type: Easing.OutQuad }
            }

            SequentialAnimation {
                id: liftAnim
                running: false
                NumberAnimation { target: card; property: "liftOffset"; from: 0; to: -4; duration: 140; easing.type: Easing.OutQuad }
                NumberAnimation { target: card; property: "liftOffset"; to: 0; duration: 180; easing.type: Easing.InOutQuad }
            }

            Rectangle {
                id: statusDimmer
                anchors.fill: parent
                radius: 0
                color: "#120D12"
                opacity: Math.min(1, statusDim + incapacitatedDim + deathDim + (deathFrameIndex === 4 ? 0.35 : 0.0))
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation { duration: 240; easing.type: Easing.OutQuad }
                }
            }

            Rectangle {
                id: leftGrayOverlay
                anchors.fill: parent
                radius: 0
                color: "#9A9A9A"
                opacity: leftGrayDim
                visible: opacity > 0
                z: 6
                Behavior on opacity {
                    NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                }
            }

            Item {
                id: statusOverlays
                anchors.fill: parent
                anchors.margins: overlayInset
                z: 4
                opacity: leftCardOpacity
                visible: turnVisualActive || concentrationVisualActive || tempHpVisualActive || concentrationTempVisualActive

                Image {
                    id: concentrationFramePrimary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: concentrationPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationVisualActive && !concentrationTempVisualActive && !turnVisualActive
                    opacity: 1.0
                    transform: Scale { xScale: overlayScaleX; yScale: overlayScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: concentrationFrameSecondary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: concentrationSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationVisualActive && !concentrationTempVisualActive && !turnVisualActive
                    opacity: 0.0
                    transform: Scale { xScale: overlayScaleX; yScale: overlayScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: tempHpFramePrimary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: tempHpPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: tempHpVisualActive && !concentrationTempVisualActive && !tempIncapActive && tempIncapFrameIndex < 0 && !turnVisualActive
                    opacity: 1.0
                    transform: Scale { xScale: tempHpScaleX; yScale: tempHpScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: tempHpFrameSecondary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: tempHpSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: tempHpVisualActive && !concentrationTempVisualActive && !tempIncapActive && tempIncapFrameIndex < 0 && !turnVisualActive
                    opacity: 0.0
                    transform: Scale { xScale: tempHpScaleX; yScale: tempHpScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: concentrationTempFramePrimary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: concentrationTempPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationTempVisualActive && !turnVisualActive
                    opacity: 1.0
                    transform: Scale {
                        xScale: (concentrationCanvasWidth / concentrationTempTargetFrameWidth) * (concentrationTempTargetFrameWidth / concentrationTempFrameWidths[concentrationTempPrimaryFrameMetaIndex])
                        yScale: (concentrationCanvasHeight / concentrationTempTargetFrameHeight) * (concentrationTempTargetFrameHeight / concentrationTempFrameHeights[concentrationTempPrimaryFrameMetaIndex])
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: concentrationTempFrameSecondary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: concentrationTempSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationTempVisualActive && !turnVisualActive
                    opacity: 0.0
                    transform: Scale {
                        xScale: (concentrationCanvasWidth / concentrationTempTargetFrameWidth) * (concentrationTempTargetFrameWidth / concentrationTempFrameWidths[concentrationTempSecondaryFrameMetaIndex])
                        yScale: (concentrationCanvasHeight / concentrationTempTargetFrameHeight) * (concentrationTempTargetFrameHeight / concentrationTempFrameHeights[concentrationTempSecondaryFrameMetaIndex])
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Timer {
                    id: concentrationTempTimer
                    interval: 100
                    running: false
                    repeat: true
                    onTriggered: {
                        var frames = concentrationTempFrames
                        if (frames.length < 3) {
                            concentrationTempTimer.stop()
                            concentrationTempVisualActive = false
                            return
                        }

                        concentrationTempFrameIndex += concentrationTempFrameDirection
                        if (concentrationTempFrameIndex < 0 || concentrationTempFrameIndex > 2) {
                            concentrationTempTimer.stop()
                            if (concentrationTempFrameDirection < 0) {
                                concentrationTempVisualActive = false
                                concentrationTempPrimarySource = ""
                                concentrationTempSecondarySource = ""
                            } else {
                                concentrationTempFrameIndex = 2
                            }
                            return
                        }

                        if (useAlternateConcentrationTempFrame) {
                            concentrationTempPrimarySource = frames[concentrationTempFrameIndex]
                            concentrationTempPrimaryFrameMetaIndex = concentrationTempFrameIndex
                            concentrationTempPrimaryTargetOpacity = 1.0
                            concentrationTempSecondaryTargetOpacity = 0.0
                        } else {
                            concentrationTempSecondarySource = frames[concentrationTempFrameIndex]
                            concentrationTempSecondaryFrameMetaIndex = concentrationTempFrameIndex
                            concentrationTempPrimaryTargetOpacity = 0.0
                            concentrationTempSecondaryTargetOpacity = 1.0
                        }
                        concentrationTempFramePrimary.opacity = concentrationTempPrimaryTargetOpacity
                        concentrationTempFrameSecondary.opacity = concentrationTempSecondaryTargetOpacity
                        useAlternateConcentrationTempFrame = !useAlternateConcentrationTempFrame
                    }
                }

                Image {
                    id: turnFramePrimary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: turnPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: turnVisualActive
                    opacity: 1.0
                    transform: Scale { xScale: overlayScaleX; yScale: overlayScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: turnFrameSecondary
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * overlayHeightScale
                    source: turnSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: turnVisualActive
                    opacity: 0.0
                    transform: Scale { xScale: overlayScaleX; yScale: overlayScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

                Timer {
                    id: turnTimer
                    interval: 100
                    running: false
                    repeat: true
                    onTriggered: {
                        var frames = turnVisualFramesForKey(turnVisualKey)
                        if (frames.length < 3) {
                            turnTimer.stop()
                            turnVisualActive = false
                            return
                        }

                        turnFrameIndex += turnFrameDirection
                        if (turnFrameIndex < 0 || turnFrameIndex > 2) {
                            turnTimer.stop()
                            if (turnFrameDirection < 0) {
                                if (pendingTurnVisualKey) {
                                    var nextFrames = turnVisualFramesForKey(pendingTurnVisualKey)
                                    turnVisualKey = pendingTurnVisualKey
                                    pendingTurnVisualKey = ""
                                    turnVisualActive = true
                                    turnFrameDirection = 1
                                    turnFrameIndex = 0
                                    useAlternateTurnFrame = false
                                    turnFramePrimary.opacity = 1.0
                                    turnFrameSecondary.opacity = 0.0
                                    turnPrimarySource = nextFrames[0]
                                    turnSecondarySource = nextFrames[0]
                                    turnTimer.restart()
                                } else {
                                    turnVisualActive = false
                                    turnPrimarySource = ""
                                    turnSecondarySource = ""
                                }
                            } else {
                                turnFrameIndex = 2
                            }
                            return
                        }

                        if (useAlternateTurnFrame) {
                            turnPrimarySource = frames[turnFrameIndex]
                            turnPrimaryTargetOpacity = 1.0
                            turnSecondaryTargetOpacity = 0.0
                        } else {
                            turnSecondarySource = frames[turnFrameIndex]
                            turnPrimaryTargetOpacity = 0.0
                            turnSecondaryTargetOpacity = 1.0
                        }
                        turnFramePrimary.opacity = turnPrimaryTargetOpacity
                        turnFrameSecondary.opacity = turnSecondaryTargetOpacity
                        useAlternateTurnFrame = !useAlternateTurnFrame
                    }
                }

                Timer {
                    id: tempHpTimer
                    interval: 100
                    running: false
                    repeat: true
                    onTriggered: {
                        var frames = tempHpFrames
                        if (frames.length < 3) {
                            tempHpTimer.stop()
                            tempHpVisualActive = false
                            return
                        }

                        tempHpFrameIndex += tempHpFrameDirection
                        if (tempHpFrameIndex < 0 || tempHpFrameIndex > 2) {
                            tempHpTimer.stop()
                            if (tempHpFrameDirection < 0) {
                                tempHpVisualActive = false
                                tempHpPrimarySource = ""
                                tempHpSecondarySource = ""
                            } else {
                                tempHpFrameIndex = 2
                            }
                            return
                        }

                        if (useAlternateTempHpFrame) {
                            tempHpPrimarySource = frames[tempHpFrameIndex]
                            tempHpPrimaryTargetOpacity = 1.0
                            tempHpSecondaryTargetOpacity = 0.0
                        } else {
                            tempHpSecondarySource = frames[tempHpFrameIndex]
                            tempHpPrimaryTargetOpacity = 0.0
                            tempHpSecondaryTargetOpacity = 1.0
                        }
                        tempHpFramePrimary.opacity = tempHpPrimaryTargetOpacity
                        tempHpFrameSecondary.opacity = tempHpSecondaryTargetOpacity
                        useAlternateTempHpFrame = !useAlternateTempHpFrame
                    }
                }

                Timer {
                    id: concentrationTimer
                    interval: 100
                    running: false
                    repeat: true
                    onTriggered: {
                        var frames = concentrationFrames
                        if (frames.length < 3) {
                            concentrationTimer.stop()
                            concentrationVisualActive = false
                            return
                        }

                        concentrationFrameIndex += concentrationFrameDirection
                        if (concentrationFrameIndex < 0 || concentrationFrameIndex > 2) {
                            concentrationTimer.stop()
                            if (concentrationFrameDirection < 0) {
                                concentrationVisualActive = false
                                concentrationPrimarySource = ""
                                concentrationSecondarySource = ""
                            } else {
                                concentrationFrameIndex = 2
                            }
                            return
                        }

                        if (useAlternateFrame) {
                            concentrationPrimarySource = frames[concentrationFrameIndex]
                            primaryTargetOpacity = 1.0
                            secondaryTargetOpacity = 0.0
                        } else {
                            concentrationSecondarySource = frames[concentrationFrameIndex]
                            primaryTargetOpacity = 0.0
                            secondaryTargetOpacity = 1.0
                        }
                        concentrationFramePrimary.opacity = primaryTargetOpacity
                        concentrationFrameSecondary.opacity = secondaryTargetOpacity
                        useAlternateFrame = !useAlternateFrame
                    }
                }

                // Opacity transition is handled via Behavior on each concentration frame.
            }

            Item {
                id: damageOverlayLayer
                anchors.fill: parent
                z: 6
                visible: damageFrameIndex >= 0

                Image {
                    id: damageFrameImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: damageFrameSource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: damageFrameIndex >= 0
                }

                Timer {
                    id: damageFrameTimer
                    interval: 100
                    repeat: true
                    running: false
                    onTriggered: {
                        if (damageFrameIndex === 2) {
                            displayedHpRatio = pendingDamageHpRatio
                        }

                        damageFrameIndex += 1
                        if (damageFrameIndex >= damageFrames.length) {
                            running = false
                            damageFrameIndex = -1
                            damageFrameSource = ""
                        } else {
                            damageFrameSource = damageFrames[damageFrameIndex]
                        }
                    }
                }

                SequentialAnimation {
                    id: damageShakeAnim
                    running: false
                    NumberAnimation { target: card; property: "shakeOffset"; from: 0; to: -2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -2; to: 2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 2; to: -2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -2; to: 2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 2; to: -1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -1; to: 1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 1; to: -1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -1; to: 1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 1; to: 0; duration: 100; easing.type: Easing.OutQuad }
                }
            }

            Item {
                id: healOverlayLayer
                anchors.fill: parent
                z: 7
                visible: healFrameIndex >= 0

                Image {
                    id: healFrameImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: healFrameSource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: healFrameIndex >= 0
                }

                Timer {
                    id: healFrameTimer
                    interval: 100
                    repeat: true
                    running: false
                    onTriggered: {
                        if (healFrameIndex === 2) {
                            displayedHpRatio = pendingHealHpRatio
                        }

                        healFrameIndex += 1
                        if (healFrameIndex >= healFrames.length) {
                            running = false
                            healFrameIndex = -1
                            healFrameSource = ""
                        } else {
                            healFrameSource = healFrames[healFrameIndex]
                        }
                    }
                }

                SequentialAnimation {
                    id: healShakeAnim
                    running: false
                    NumberAnimation { target: card; property: "shakeOffset"; from: 0; to: -2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -2; to: 2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 2; to: -2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -2; to: 2; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 2; to: -1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -1; to: 1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 1; to: -1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: -1; to: 1; duration: 50; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: card; property: "shakeOffset"; from: 1; to: 0; duration: 100; easing.type: Easing.OutQuad }
                }
            }

            Item {
                id: tempIncapOverlayLayer
                anchors.fill: parent
                z: 8
                visible: tempIncapFrameIndex >= 0

                Image {
                    id: tempIncapFramePrimary
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 6
                    width: parent.width
                    height: parent.height
                    source: tempIncapPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: tempIncapFrameIndex >= 0
                    opacity: 1.0
                    transform: Scale {
                        xScale: tempIncapScaleX
                        yScale: tempIncapScaleY
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
                    }
                }

            }

            Item {
                id: incapacitatedOverlayLayer
                anchors.fill: parent
                z: 9
                visible: incapacitatedFrameIndex >= 0 && !tempIncapActive

                Image {
                    id: incapacitatedFrameImage
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 6
                    width: parent.width
                    height: parent.height
                    source: incapacitatedFrameSource
                    fillMode: Image.Stretch
                    visible: incapacitatedFrameIndex >= 0
                    transform: Scale {
                        xScale: incapacitatedScaleX
                        yScale: incapacitatedScaleY
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                }
            }

            Item {
                id: deathOverlayLayer
                anchors.fill: parent
                z: 10
                visible: deathFrameIndex >= 0

                Image {
                    id: deathFrameImage
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: deathOverlayOffsetY
                    anchors.horizontalCenterOffset: deathOverlayOffsetX
                    width: parent.width
                    height: parent.height
                    source: deathFrameSource
                    sourceClipRect: Qt.rect(
                        activeDeathFrameOpaqueRect.x,
                        activeDeathFrameOpaqueRect.y,
                        activeDeathFrameOpaqueRect.width,
                        activeDeathFrameOpaqueRect.height
                    )
                    fillMode: Image.Stretch
                    smooth: true
                    visible: deathFrameIndex >= 0
                    transform: Scale {
                        xScale: deathFitScaleX
                        yScale: deathFitScaleY
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                }
            }

            Item {
                id: leftOverlayLayer
                anchors.fill: parent
                z: 11
                visible: leftTavernFrameIndex >= 0

                Image {
                    id: leftTavernFrameImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: leftTavernFrameSource
                    sourceClipRect: Qt.rect(
                        activeLeftTavernOpaqueRect.x,
                        activeLeftTavernOpaqueRect.y,
                        activeLeftTavernOpaqueRect.width,
                        activeLeftTavernOpaqueRect.height
                    )
                    fillMode: Image.Stretch
                    smooth: true
                    visible: leftTavernFrameIndex >= 0
                    transform: Scale {
                        xScale: leftTavernFitScaleX * leftTavernForcedScaleX * leftTavernScaleBoostX
                        yScale: leftTavernFitScaleY * leftTavernForcedScaleY * leftTavernScaleBoostY
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                }

                Image {
                    id: leftWantedFrameImage
                    anchors.centerIn: parent
                    source: leftWantedFrameSource
                    width: parent.width * leftWantedScale
                    height: parent.height * leftWantedScale
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: leftWantedFrameIndex >= 0
                }
            }

            Item {
                id: contentArea
                z: 3
                opacity: leftCardOpacity
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.bottomMargin: 12
                anchors.topMargin: statusBar.height + 16

                Rectangle {
                    id: nameContainer
                    height: Math.max(20, Math.round(30 * cardUiScale))
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    color: "#1A141C"
                    border.width: 1
                    border.color: "#3B2D35"
                    z: 3

                    Text {
                        id: nameText
                        anchors.centerIn: parent
                        width: parent.width - 10
                        text: displayName
                        color: inkLight
                        font.pixelSize: Math.max(11, Math.round(21 * cardUiScale))
                        font.family: pixelFont.name
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    id: smokeOverlay
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: nameContainer.bottom
                    anchors.bottom: parent.bottom
                    color: accentSmoke
                    opacity: 0.0
                    visible: opacity > 0
                    z: 2
                }

                Column {
                    id: detailsColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: nameContainer.bottom
                    anchors.bottom: parent.bottom
                    spacing: 8

                    Row {
                        spacing: 8
                        visible: showHpText
                        Text {
                            text: hp === null ? "HP —" : ("HP " + hp + " / " + max_hp)
                            color: inkMuted
                            font.pixelSize: Math.max(10, Math.round(16 * cardUiScale))
                            font.family: pixelFont.name
                        }
                        Text {
                            text: tempHpValue > 0 ? ("+ " + tempHpValue) : ""
                            color: accentCool
                            font.pixelSize: Math.max(9, Math.round(14 * cardUiScale))
                            font.family: pixelFont.name
                            visible: tempHpValue > 0
                        }
                    }

                    Rectangle {
                        id: hpBar
                        height: Math.max(6, Math.round(12 * cardUiScale))
                        radius: 0
                        visible: showHpBar
                        color: barBackground
                        border.width: 1
                        border.color: panelEdge
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Rectangle {
                            id: hpLossTrail
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            radius: 0
                            color: damageFillColor
                            opacity: 0.0
                        }

                        Rectangle {
                            id: hpFill
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * displayedHpRatio
                            radius: 0
                            color: hpFillColor
                        }

                        Rectangle {
                            id: tempHpFill
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: tempHpValue > 0 ? Math.min(parent.width * 0.25, parent.width * (tempHpValue / (max_hp || 1))) : 0
                            radius: 0
                            color: accentTemp
                            visible: tempHpValue > 0
                            opacity: tempHpPulse.opacity
                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }

                        SequentialAnimation {
                            id: tempHpPulse
                            property real opacity: 1
                            running: tempHpValue > 0
                            loops: Animation.Infinite
                            NumberAnimation { target: tempHpPulse; property: "opacity"; from: 0.9; to: 1; duration: 900; easing.type: Easing.InOutQuad }
                            NumberAnimation { target: tempHpPulse; property: "opacity"; from: 1; to: 0.9; duration: 900; easing.type: Easing.InOutQuad }
                        }

                        Item {
                            id: tempHpShards
                            anchors.fill: parent
                            visible: shardBurst.running
                            Repeater {
                                model: 6
                                Rectangle {
                                    width: 6
                                    height: 2
                                    radius: 0
                                    color: accentTemp
                                    x: (index % 3) * 18 + 12 + shardBurst.progress * ((index % 3) - 1) * 14
                                    y: Math.floor(index / 3) * 6 + 2 + shardBurst.progress * ((index % 2) ? -8 : 8)
                                    opacity: 1 - shardBurst.progress
                                    rotation: shardBurst.progress * 60 * (index % 2 === 0 ? 1 : -1)
                                }
                            }
                        }

                        SequentialAnimation {
                            id: shardBurst
                            property real progress: 0
                            running: false
                            NumberAnimation { target: shardBurst; property: "progress"; from: 0; to: 1; duration: 220; easing.type: Easing.OutQuad }
                            ScriptAction { script: shardBurst.progress = 0 }
                        }
                    }

                    Item {
                        id: incapacitatedField
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 10
                        visible: incapacitatedOpacity > 0.01
                        opacity: incapacitatedOpacity
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.7
                            height: 2
                            color: "#6d5a42"
                            opacity: 0.5
                        }
                    }

                    Grid {
                        id: customEffectsGrid
                        columns: customEffectColumns
                        spacing: Math.max(2, Math.round(4 * cardUiScale))
                        width: parent.width
                        clip: true
                        visible: customEffectSlots > 0

                        Repeater {
                            model: displayCustomEffects
                            delegate: Rectangle {
                                width: (customEffectsGrid.width - customEffectsGrid.spacing * (customEffectsGrid.columns - 1)) / customEffectsGrid.columns
                                height: Math.max(14, Math.round(22 * cardUiScale))
                                radius: 0
                                color: "#1A141C"
                                border.width: 1
                                border.color: "#3B2D35"

                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - 10
                                    text: modelData
                                    color: inkLight
                                    font.pixelSize: Math.max(9, Math.round(14 * cardUiScale))
                                    font.family: pixelFont.name
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                if (concentrationActive) {
                    concentrationVisualActive = true
                    concentrationPrimarySource = concentrationFrames[2]
                    concentrationSecondarySource = concentrationFrames[2]
                    concentrationFramePrimary.opacity = 1.0
                    concentrationFrameSecondary.opacity = 0.0
                }
                if (tempHpValue > 0) {
                    tempHpVisualActive = true
                    tempHpPrimarySource = tempHpFrames[2]
                    tempHpSecondarySource = tempHpFrames[2]
                    tempHpFramePrimary.opacity = 1.0
                    tempHpFrameSecondary.opacity = 0.0
                }
                if (concentrationTempActive) {
                    concentrationTempVisualActive = true
                    concentrationTempPrimarySource = concentrationTempFrames[2]
                    concentrationTempSecondarySource = concentrationTempFrames[2]
                    concentrationTempPrimaryFrameMetaIndex = 2
                    concentrationTempSecondaryFrameMetaIndex = 2
                    concentrationTempFramePrimary.opacity = 1.0
                    concentrationTempFrameSecondary.opacity = 0.0
                }
                var initTurnKey = desiredTurnVisualKey()
                if (initTurnKey) {
                    turnVisualActive = true
                    turnVisualKey = initTurnKey
                    var initTurnFrames = turnVisualFramesForKey(initTurnKey)
                    turnPrimarySource = initTurnFrames[2]
                    turnSecondarySource = initTurnFrames[2]
                    turnFramePrimary.opacity = 1.0
                    turnFrameSecondary.opacity = 0.0
                }
            }

            onHpValueChanged: {
                if (hpValue === null || lastHp === null || hpValue === undefined || lastHp === undefined) {
                    lastHp = hpValue
                    lastHpRatio = hpRatio
                    displayedHpRatio = hpRatio
                    pendingDamageHpRatio = hpRatio
                    pendingHealHpRatio = hpRatio
                    return
                }
                if (hpValue < lastHp) {
                    flashColor = damageFillColor
                    flashPeak = 0.35
                    flashAnim.restart()
                    hpLossTrail.x = hpBar.width * hpRatio
                    hpLossTrail.width = Math.max(0, hpBar.width * (lastHpRatio - hpRatio))
                    hpLossTrail.opacity = 0.8
                    hpLossTrailAnimation.restart()
                    startDamageSequence(hpRatio)
                } else if (hpValue > lastHp) {
                    flashColor = hpFillColor
                    flashPeak = 0.28
                    flashAnim.restart()
                    liftAnim.restart()
                    startHealSequence(hpRatio)
                }
                lastHp = hpValue
                lastHpRatio = hpRatio
            }

            SequentialAnimation {
                id: hpLossTrailAnimation
                running: false
                PropertyAnimation { target: hpLossTrail; property: "opacity"; from: 0.8; to: 0.0; duration: 100; easing.type: Easing.OutQuad }
            }

            onTempHpValueChanged: {
                if (lastTempHp === undefined || lastTempHp === null) {
                    lastTempHp = tempHpValue
                    return
                }
                if (tempHpValue > 0 && lastTempHp <= 0) {
                    tempHpAppear.restart()
                }
                if (tempHpValue <= 0 && lastTempHp > 0) {
                    shardBurst.restart()
                }
                if (tempHpValue < lastTempHp && !(hpValue < lastHp) && !damageFrameTimer.running) {
                    flashColor = damageFillColor
                    flashPeak = 0.35
                    flashAnim.restart()
                    startDamageSequence(hpRatio)
                }
                if (tempHpValue > lastTempHp && !(hpValue > lastHp) && !healFrameTimer.running) {
                    flashColor = hpFillColor
                    flashPeak = 0.28
                    flashAnim.restart()
                    startHealSequence(hpRatio)
                }
                if (tempHpValue > 0 && !tempHpVisualActive) {
                    tempHpVisualActive = true
                    tempHpFrameDirection = 1
                    tempHpFrameIndex = 0
                    useAlternateTempHpFrame = false
                    tempHpFramePrimary.opacity = 1.0
                    tempHpFrameSecondary.opacity = 0.0
                    tempHpPrimarySource = tempHpFrames[0]
                    tempHpSecondarySource = tempHpFrames[0]
                    tempHpTimer.restart()
                } else if (tempHpValue <= 0 && tempHpVisualActive) {
                    tempHpFrameDirection = -1
                    tempHpFrameIndex = 2
                    tempHpTimer.restart()
                }
                refreshTurnVisual()
                lastTempHp = tempHpValue
            }

            onTempIncapActiveChanged: {
                if (lastTempIncapActive === tempIncapActive) {
                    return
                }
                if (stateValue === "dead" || stateValue === "left") {
                    clearIncapacitatedVisuals()
                    lastTempIncapActive = tempIncapActive
                    return
                }
                if (tempIncapActive) {
                    startTempIncapForward()
                } else if (incapacitatedActive && stateValue === "alive") {
                    stopTempIncapAnimations()
                    setTempIncapFrame(-1)
                    stopIncapacitatedAnimations()
                    incapacitatedDim = 0.28
                    incapacitatedScaleFactor = incapacitatedShrinkScale
                    setIncapacitatedFrame(4)
                } else {
                    startTempIncapReverse()
                }
                lastTempIncapActive = tempIncapActive
            }

            SequentialAnimation {
                id: tempHpAppear
                running: false
                PropertyAnimation { target: tempHpFill; property: "opacity"; from: 0.0; to: 1.0; duration: 90; easing.type: Easing.OutQuad }
            }

            onConcentrationActiveChanged: {
                if (concentrationActive) {
                    concentrationVisualActive = true
                    concentrationFrameDirection = 1
                    concentrationFrameIndex = 0
                    useAlternateFrame = false
                    concentrationFramePrimary.opacity = 1.0
                    concentrationFrameSecondary.opacity = 0.0
                    concentrationPrimarySource = concentrationFrames[0]
                    concentrationSecondarySource = concentrationFrames[0]
                    concentrationTimer.restart()
                } else if (concentrationVisualActive) {
                    concentrationFrameDirection = -1
                    concentrationFrameIndex = 2
                    concentrationTimer.restart()
                }
                refreshTurnVisual()
                lastConcentration = concentrationActive
            }

            onConcentrationTempActiveChanged: {
                if (concentrationTempActive) {
                    concentrationTempVisualActive = true
                    concentrationTempFrameDirection = 1
                    concentrationTempFrameIndex = 0
                    useAlternateConcentrationTempFrame = false
                    concentrationTempFramePrimary.opacity = 1.0
                    concentrationTempFrameSecondary.opacity = 0.0
                    concentrationTempPrimarySource = concentrationTempFrames[0]
                    concentrationTempSecondarySource = concentrationTempFrames[0]
                    concentrationTempPrimaryFrameMetaIndex = 0
                    concentrationTempSecondaryFrameMetaIndex = 0
                    concentrationTempTimer.restart()
                } else if (concentrationTempVisualActive) {
                    concentrationTempFrameDirection = -1
                    concentrationTempFrameIndex = 2
                    concentrationTempTimer.restart()
                }
            }

            onTurnOverlayActiveChanged: refreshTurnVisual()


            onIncapacitatedActiveChanged: {
                if (lastIncapacitated === incapacitatedActive) {
                    return
                }
                if (stateValue === "dead") {
                    clearIncapacitatedVisuals()
                    lastIncapacitated = incapacitatedActive
                    return
                }
                if (stateValue === "left") {
                    suppressIncapacitatedReverseAfterLeft = false
                    clearIncapacitatedVisuals()
                    lastIncapacitated = incapacitatedActive
                    return
                }
                if (suppressIncapacitatedReverseAfterLeft && stateValue === "alive" && !incapacitatedActive) {
                    suppressIncapacitatedReverseAfterLeft = false
                    clearIncapacitatedVisuals()
                    lastIncapacitated = incapacitatedActive
                    return
                }
                if (tempIncapActive || tempIncapFrameIndex >= 0) {
                    lastIncapacitated = incapacitatedActive
                    return
                }
                if (incapacitatedActive && stateValue === "alive") {
                    startIncapacitatedForward()
                } else {
                    startIncapacitatedReverse()
                }
                lastIncapacitated = incapacitatedActive
            }

            SequentialAnimation {
                id: incapacitatedForward
                running: false
                ScriptAction { script: setIncapacitatedFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(1) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(2) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(3) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(4) }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "incapacitatedDim"; to: 0.28; duration: 100; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "incapacitatedScaleFactor"; to: incapacitatedShrinkScale; duration: 100; easing.type: Easing.OutQuad }
                }
            }

            SequentialAnimation {
                id: incapacitatedReverse
                running: false
                ScriptAction { script: setIncapacitatedFrame(4) }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "incapacitatedDim"; to: 0.0; duration: 100; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "incapacitatedScaleFactor"; to: 1.0; duration: 100; easing.type: Easing.OutQuad }
                }
                ScriptAction { script: setIncapacitatedFrame(3) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(2) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(1) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setIncapacitatedFrame(-1) }
            }

            SequentialAnimation {
                id: tempIncapForward
                running: false
                ScriptAction { script: setTempIncapFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(1) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(2) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(3) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(4) }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "incapacitatedDim"; to: 0.28; duration: 100; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "incapacitatedScaleFactor"; to: incapacitatedShrinkScale; duration: 100; easing.type: Easing.OutQuad }
                }
            }

            SequentialAnimation {
                id: tempIncapReverse
                running: false
                ScriptAction { script: setTempIncapFrame(4) }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "incapacitatedDim"; to: 0.0; duration: 100; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "incapacitatedScaleFactor"; to: 1.0; duration: 100; easing.type: Easing.OutQuad }
                }
                ScriptAction { script: setTempIncapFrame(3) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(2) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(1) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setTempIncapFrame(-1) }
            }

            SequentialAnimation {
                id: deathForward
                running: false
                ScriptAction { script: setDeathFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setDeathFrame(1) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setDeathFrame(2) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setDeathFrame(3) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setDeathFrame(4) }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "deathDim"; to: 0.85; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "incapacitatedScaleFactor"; to: incapacitatedShrinkScale; duration: 120; easing.type: Easing.OutQuad }
                }
            }


            SequentialAnimation {
                id: leftBattleForward
                running: false
                ScriptAction { script: setLeftTavernFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftTavernFrame(1) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftTavernFrame(2) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftWantedFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftWantedFrame(1) }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "leftGrayDim"; to: 0.32; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "leftCardOpacity"; to: 0.72; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "leftScaleFactor"; to: incapacitatedShrinkScale; duration: 120; easing.type: Easing.OutQuad }
                }
            }

            SequentialAnimation {
                id: leftBattleReverse
                running: false
                ScriptAction { script: setLeftWantedFrame(1) }
                ParallelAnimation {
                    NumberAnimation { target: card; property: "leftGrayDim"; to: 0.0; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "leftCardOpacity"; to: 1.0; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: card; property: "leftScaleFactor"; to: 1.0; duration: 120; easing.type: Easing.OutQuad }
                }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftWantedFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftWantedFrame(-1) }
                ScriptAction { script: setLeftTavernFrame(2) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftTavernFrame(1) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftTavernFrame(0) }
                PauseAnimation { duration: 100 }
                ScriptAction { script: setLeftTavernFrame(-1) }
            }

            onIsActiveChanged: refreshTurnVisual()

            onStateValueChanged: {
                refreshTurnVisual()
                if (lastState === stateValue) {
                    return
                }
                if (lastState === "left" && stateValue !== "left") {
                    pendingStateVisual = stateValue
                    suppressIncapacitatedReverseAfterLeft = true
                    statusDelayTimer.stop()
                    startLeftReverse()
                    statusDelayTimer.restart()
                    lastState = stateValue
                    return
                }
                if (stateValue === "dead") {
                    clearLeftVisuals()
                    pendingStateVisual = ""
                    statusDelayTimer.stop()
                    applyStateVisuals(stateValue)
                    if (deathFrameIndex < 0) {
                        startDeathForward()
                    }
                    lastState = stateValue
                    return
                }
                if (lastState === "dead" && stateValue !== "dead") {
                    clearDeathVisuals()
                }
                if (stateValue === "left") {
                    pendingStateVisual = ""
                    statusDelayTimer.stop()
                    applyStateVisuals(stateValue)
                    if (leftTavernFrameIndex < 0 || leftWantedFrameIndex < 1) {
                        startLeftForward()
                    }
                    lastState = stateValue
                    return
                }
                if (lastState === "alive" && stateValue !== "alive" && (incapacitatedActive || incapacitatedFrameIndex >= 0 || tempIncapFrameIndex >= 0 || tempIncapActive)) {
                    pendingStateVisual = stateValue
                    if (tempIncapActive || tempIncapFrameIndex >= 0) {
                        startTempIncapReverse()
                    } else {
                        startIncapacitatedReverse()
                    }
                    statusDelayTimer.restart()
                } else {
                    applyStateVisuals(stateValue)
                    if (stateValue === "alive" && tempIncapActive && tempIncapFrameIndex < 0) {
                        startTempIncapForward()
                    } else if (stateValue === "alive" && incapacitatedActive && incapacitatedFrameIndex < 0) {
                        startIncapacitatedForward()
                    }
                }
                lastState = stateValue
            }

            Timer {
                id: statusDelayTimer
                interval: 620
                repeat: false
                onTriggered: {
                    if (pendingStateVisual) {
                        var deferredState = pendingStateVisual
                        applyStateVisuals(deferredState)
                        suppressIncapacitatedReverseAfterLeft = false
                        if (deferredState === "dead" && deathFrameIndex < 0) {
                            startDeathForward()
                        } else if (deferredState === "alive") {
                            if (tempIncapActive && tempIncapFrameIndex < 0) {
                                startTempIncapForward()
                            } else if (incapacitatedActive && incapacitatedFrameIndex < 0) {
                                startIncapacitatedForward()
                            }
                        }
                        pendingStateVisual = ""
                    }
                }
            }

            SequentialAnimation {
                id: smokeFadeIn
                running: false
                PropertyAnimation { target: smokeOverlay; property: "opacity"; from: 0.0; to: 0.55; duration: 380; easing.type: Easing.OutQuad }
            }

            SequentialAnimation {
                id: smokeFadeOut
                running: false
                PropertyAnimation { target: smokeOverlay; property: "opacity"; from: smokeOverlay.opacity; to: 0.0; duration: 280; easing.type: Easing.OutQuad }
            }
            }
        }

    }

    Item {
        id: pixelParticleLayer
        anchors.fill: parent
        z: 999
        clip: true

        property string pixelTexturePath: "textures/"
        property var pixelNames: ["pixel1", "pixel2", "pixel3", "pixel4", "pixel5"]
        property string pixelExtension: ".png"

        function randomPixelSource() {
            var idx = randomInt(0, pixelNames.length - 1)
            return pixelTexturePath + pixelNames[idx] + pixelExtension
        }
        property int poolSize: 16

        function randomBetween(minValue, maxValue) {
            return minValue + Math.random() * (maxValue - minValue)
        }

        function randomInt(minValue, maxValue) {
            return Math.floor(randomBetween(minValue, maxValue + 1))
        }

        function nextSpawnInterval() {
            return randomInt(5000, 60000)
        }

        function spawnOne() {
            for (var i = 0; i < particleRepeater.count; i += 1) {
                var particle = particleRepeater.itemAt(i)
                if (particle && !particle.active) {
                    particle.launch()
                    return
                }
            }
        }

        function spawnBurst() {
            spawnOne()
            if (Math.random() < 0.05) {
                spawnOne()
            }
        }

        Timer {
            id: particleSpawner
            interval: pixelParticleLayer.nextSpawnInterval()
            repeat: true
            running: true
            triggeredOnStart: false
            onTriggered: {
                pixelParticleLayer.spawnBurst()
                interval = pixelParticleLayer.nextSpawnInterval()
            }
        }

        Repeater {
            id: particleRepeater
            model: pixelParticleLayer.poolSize

            delegate: Item {
                id: particle
                visible: active
                opacity: 0.0

                property bool active: false
                property real spriteBaseSize: 30
                property real particleScale: 1.0
                property string textureSource: ""
                property real trailFactor: 1.0
                property real glowFactor: 1.0
                property int travelDuration: 16000

                function launch() {
                    var startX = pixelParticleLayer.randomBetween(0, Math.max(1, pixelParticleLayer.width - spriteBaseSize * 2))
                    var startY = pixelParticleLayer.height + pixelParticleLayer.randomBetween(8, 40)
                    var endX = Math.max(0, Math.min(pixelParticleLayer.width - width, startX + pixelParticleLayer.randomBetween(-140, 140)))
                    var firstMidX = Math.max(0, Math.min(pixelParticleLayer.width - width, startX + pixelParticleLayer.randomBetween(-80, 80)))
                    var secondMidX = Math.max(0, Math.min(pixelParticleLayer.width - width, startX + pixelParticleLayer.randomBetween(-100, 100)))
                    var firstMidY = pixelParticleLayer.randomBetween(pixelParticleLayer.height * 0.75, pixelParticleLayer.height * 0.92)
                    var secondMidY = pixelParticleLayer.randomBetween(pixelParticleLayer.height * 0.35, pixelParticleLayer.height * 0.62)
                    var targetTopY = pixelParticleLayer.randomBetween(-70, -18)
                    var fadeEarly = Math.random() < 0.5

                    textureSource = pixelParticleLayer.randomPixelSource()
                    particleScale = pixelParticleLayer.randomBetween(1.0, 1.5)
                    trailFactor = pixelParticleLayer.randomBetween(1.0, 1.5)
                    glowFactor = pixelParticleLayer.randomBetween(1.0, 1.5)
                    travelDuration = pixelParticleLayer.randomInt(10000, 22000)
                    var fadeHold = fadeEarly ? Math.floor(travelDuration * pixelParticleLayer.randomBetween(0.35, 0.8)) : Math.max(0, travelDuration - 2200)

                    x = startX
                    y = startY
                    opacity = 0.0
                    active = true

                    xSeg1.to = firstMidX
                    xSeg2.to = secondMidX
                    xSeg3.to = endX

                    ySeg1.to = firstMidY
                    ySeg2.to = secondMidY
                    ySeg3.to = targetTopY

                    var seg1 = Math.floor(travelDuration * pixelParticleLayer.randomBetween(0.22, 0.36))
                    var seg2 = Math.floor(travelDuration * pixelParticleLayer.randomBetween(0.24, 0.38))
                    var seg3 = Math.max(1000, travelDuration - seg1 - seg2)

                    xSeg1.duration = seg1
                    xSeg2.duration = seg2
                    xSeg3.duration = seg3
                    ySeg1.duration = seg1
                    ySeg2.duration = seg2
                    ySeg3.duration = seg3

                    fadePause.duration = fadeHold
                    fadeOut.duration = fadeEarly ? pixelParticleLayer.randomInt(1400, 2600) : pixelParticleLayer.randomInt(1800, 2800)

                    motionAnim.restart()
                    fadeAnim.restart()
                }

                function stopParticle() {
                    motionAnim.stop()
                    fadeAnim.stop()
                    active = false
                    opacity = 0.0
                }

                width: spriteBaseSize * particleScale
                height: spriteBaseSize * particleScale

                Image {
                    id: trailFar
                    anchors.centerIn: parent
                    source: particle.textureSource
                    width: parent.width * trailFactor
                    height: parent.height * trailFactor
                    opacity: parent.opacity * 0.11
                    y: 10
                    smooth: true
                }

                Image {
                    id: trailNear
                    anchors.centerIn: parent
                    source: particle.textureSource
                    width: parent.width * trailFactor
                    height: parent.height * trailFactor
                    opacity: parent.opacity * 0.2
                    y: 5
                    smooth: true
                }

                Image {
                    id: glowSprite
                    anchors.centerIn: parent
                    source: particle.textureSource
                    width: parent.width * glowFactor
                    height: parent.height * glowFactor
                    opacity: parent.opacity * 0.18
                    smooth: true
                }

                Image {
                    anchors.centerIn: parent
                    source: particle.textureSource
                    width: parent.width * glowFactor * 1.35
                    height: parent.height * glowFactor * 1.35
                    opacity: parent.opacity * 0.08
                    smooth: true
                }

                Image {
                    anchors.centerIn: parent
                    source: particle.textureSource
                    width: parent.width
                    height: parent.height
                    opacity: parent.opacity
                    smooth: true
                }

                ParallelAnimation {
                    id: motionAnim
                    running: false

                    SequentialAnimation {
                        NumberAnimation { id: xSeg1; target: particle; property: "x"; easing.type: Easing.InOutSine }
                        NumberAnimation { id: xSeg2; target: particle; property: "x"; easing.type: Easing.InOutSine }
                        NumberAnimation { id: xSeg3; target: particle; property: "x"; easing.type: Easing.InOutSine }
                    }

                    SequentialAnimation {
                        NumberAnimation { id: ySeg1; target: particle; property: "y"; easing.type: Easing.InQuad }
                        NumberAnimation { id: ySeg2; target: particle; property: "y"; easing.type: Easing.InQuad }
                        NumberAnimation { id: ySeg3; target: particle; property: "y"; easing.type: Easing.InQuad }
                    }

                    onStopped: {
                        if (particle.active) {
                            particle.active = false
                            particle.opacity = 0.0
                        }
                    }
                }

                SequentialAnimation {
                    id: fadeAnim
                    running: false
                    NumberAnimation { target: particle; property: "opacity"; from: 0.0; to: 0.75; duration: 900; easing.type: Easing.OutQuad }
                    PauseAnimation { id: fadePause }
                    NumberAnimation { id: fadeOut; target: particle; property: "opacity"; to: 0.0; easing.type: Easing.OutQuad }
                    ScriptAction { script: particle.stopParticle() }
                }
                    }
                }
            }
        }
    }
}
