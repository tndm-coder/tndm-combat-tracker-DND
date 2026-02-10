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

    property int columns: {
        var count = playerModel ? playerModel.count : 0
        if (count <= 2) return 1
        if (count <= 8) return 2
        return 3
    }
    property int rowCount: {
        var count = playerModel ? playerModel.count : 0
        if (count === 0) return 1
        return Math.ceil(count / columns)
    }
    property int columnGap: 20
    property int rowGap: 16
    property int cardMinHeight: 88
    property int cardMaxHeight: 180
    property int cardHeight: {
        var usable = height - header.height - 40
        var candidate = Math.floor((usable - (rowCount - 1) * rowGap) / rowCount)
        return Math.max(cardMinHeight, Math.min(cardMaxHeight, candidate))
    }
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
    property real headerIconSize: headerPanel.height * 0.6

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
            height: 82
            radius: 0
            color: "#2B2028"
            border.width: 1
            border.color: panelEdge

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Item {
                    id: sigil
                    width: headerIconSize
                    height: headerIconSize

                    Image {
                        id: timeSigil
                        anchors.fill: parent
                        source: "textures/time.png" // TODO: заменить на локальную иконку песочных часов (textures/time.png).
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        rotation: 0
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        id: sigilFallback
                        anchors.fill: parent
                        radius: 0
                        color: panelMid
                        border.width: 1
                        border.color: panelEdge
                        visible: timeSigil.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "⟲"
                            color: inkLight
                            font.pixelSize: 16
                            font.family: pixelFont.name
                        }
                    }

                    RotationAnimator on rotation {
                        id: sigilSpin
                        from: 0
                        to: 360
                        duration: 4200
                        loops: Animation.Infinite
                        running: true
                    }
                }

                Column {
                    spacing: 4
                    Text {
                        text: "Хроника"
                        color: inkLight
                        font.pixelSize: 26
                        font.family: pixelFont.name
                    }
                    Text {
                        text: (playerState && playerState.running) ? ("Раунд " + playerState.round) : "Ожидание боя"
                        color: (playerState && playerState.running) ? inkLight : inkSoft
                        font.pixelSize: 18
                        font.family: pixelFont.name
                    }
                }

                Item {
                    width: 1
                    height: 1
                    Layout.fillWidth: true
                }

                Row {
                    spacing: 10
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    height: headerIconSize

                    Text {
                        text: (playerState && playerState.running) ? "Идет бой" : "Тишина"
                        color: inkLight
                        font.pixelSize: 26
                        font.family: pixelFont.name
                        verticalAlignment: Text.AlignVCenter
                        height: headerIconSize
                    }

                    Image {
                        id: battleStateIcon
                        width: headerIconSize
                        height: headerIconSize
                        source: (playerState && playerState.running) ? "textures/battle.png" : "textures/calm.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: status === Image.Ready
                    }
                }
            }
        }
    }

    GridView {
        id: grid
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        model: playerModel
        cellWidth: Math.floor((width - (columns - 1) * columnGap) / columns)
        cellHeight: cardHeight + rowGap
        flow: GridView.TopToBottom
        layoutDirection: Qt.LeftToRight
        delegate: Rectangle {
            id: card
            width: grid.cellWidth
            height: grid.cellHeight - rowGap
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
            property real activeScaleBoost: is_active ? 1.03 : 1.0
            scale: baseScale * incapacitatedScaleFactor * activeScaleBoost
            transformOrigin: Item.Center

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
            property color statusFlashColor: "transparent"
            property real statusFlashPeak: 0.4
            property bool isActive: is_active
            property string stateValue: model.state ? model.state : "alive"
            property int tempHpValue: temp_hp
            property string lastState: stateValue
            property var lastTempHp: tempHpValue
            property int maxEffects: 10
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
            property var visibleEffects: {
                if (effectList.length > maxEffects) {
                    return effectList.slice(0, maxEffects - 1).concat(["…"])
                }
                return effectList
            }
            property bool concentrationActive: effects && effects.concentration
            property bool lastConcentration: concentrationActive
            property int concentrationFrameIndex: 0
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
            property string tempHpPrimarySource: ""
            property string tempHpSecondarySource: ""
            property var tempHpFrames: [
                "textures/temphp1.png",
                "textures/temphp2.png",
                "textures/temphp3.png"
            ]
            property bool concentrationTempActive: concentrationActive && tempHpValue > 0
            property int concentrationTempTargetFrameWidth: concentrationFrameWidth
            property int concentrationTempTargetFrameHeight: concentrationFrameHeight
            property var concentrationTempFrameWidths: [1187, 1152, 1173]
            property var concentrationTempFrameHeights: [547, 510, 492]
            property int concentrationTempFrameIndex: 0
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
            property int overlayRightTrim: 8
            property bool incapacitatedActive: effects && effects.incapacitated
            property bool incapacitatedEligible: incapacitatedActive && stateValue === "alive"
            property bool tempIncapActive: incapacitatedEligible && tempHpValue > 0
            property bool lastIncapacitated: incapacitatedActive
            property bool lastTempIncapActive: tempIncapActive
            property real incapacitatedOpacity: incapacitatedEligible ? 1 : 0
            property real incapacitatedDim: 0.0
            property real incapacitatedScaleFactor: 1.0
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
            property string pendingStateVisual: ""
            property real activeGlowOpacity: isActive ? 0.25 : 0.0
            property var activeGlowFrames: [
                "textures/sunshine1.png",
                "textures/sunshine2.png",
                "textures/sunshine3.png"
            ]
            property int activeGlowFrameIndex: 0
            property string activeGlowPrimarySource: ""
            property string activeGlowSecondarySource: ""
            property bool useAlternateActiveGlowFrame: false
            property real activeGlowPrimaryTargetOpacity: 0.45
            property real activeGlowSecondaryTargetOpacity: 0.0
            property real activeGlowPrimaryScaleBoost: 1.08
            property real activeGlowSecondaryScaleBoost: 1.08
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
                    statusDim = 0.7
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

            function stopTempIncapAnimations() {
                tempIncapForward.stop()
                tempIncapReverse.stop()
            }

            function startIncapacitatedForward() {
                stopIncapacitatedAnimations()
                incapacitatedDim = 0.0
                incapacitatedScaleFactor = 1.0
                setIncapacitatedFrame(0)
                incapacitatedForward.restart()
            }

            function startIncapacitatedReverse() {
                stopIncapacitatedAnimations()
                if (incapacitatedFrameIndex < 0) {
                    setIncapacitatedFrame(4)
                }
                incapacitatedReverse.restart()
            }

            function startTempIncapForward() {
                stopTempIncapAnimations()
                stopIncapacitatedAnimations()
                setIncapacitatedFrame(-1)
                incapacitatedDim = 0.0
                incapacitatedScaleFactor = 1.0
                setTempIncapFrame(0)
                tempIncapForward.restart()
            }

            function startTempIncapReverse() {
                stopTempIncapAnimations()
                stopIncapacitatedAnimations()
                setIncapacitatedFrame(-1)
                if (tempIncapFrameIndex < 0) {
                    setTempIncapFrame(4)
                }
                tempIncapReverse.restart()
            }

            transform: [
                Translate { x: shakeOffset; y: liftOffset }
            ]

            Rectangle {
                id: statusBar
                height: 36
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                radius: 0
                color: "#32252D"
                border.width: 1
                border.color: isActive ? "#FFF4AE" : panelEdge
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
                    font.pixelSize: 17
                    font.family: pixelFont.name
                }
            }

            Rectangle {
                id: activeGlow
                anchors.fill: parent
                anchors.margins: -8
                radius: 0
                color: "#FFF5BD"
                border.width: 1
                border.color: "#FFFDE8"
                opacity: activeGlowOpacity * 0.12
                visible: isActive || activeGlowOpacity > 0.01
                z: -3
            }

            Item {
                id: activeTurnGlowLayer
                anchors.fill: parent
                visible: isActive && activeGlowFrames.length > 0
                z: -4

                Image {
                    id: activeGlowFramePrimary
                    anchors.centerIn: parent
                    width: parent.width * activeGlowPrimaryScaleBoost
                    height: parent.height * activeGlowPrimaryScaleBoost
                    source: activeGlowPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    opacity: 0.0
                    visible: activeTurnGlowLayer.visible
                    Behavior on opacity {
                        NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: activeGlowFrameSecondary
                    anchors.centerIn: parent
                    width: parent.width * activeGlowSecondaryScaleBoost
                    height: parent.height * activeGlowSecondaryScaleBoost
                    source: activeGlowSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    opacity: 0.0
                    visible: activeTurnGlowLayer.visible
                    Behavior on opacity {
                        NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
                    }
                }

                Timer {
                    id: activeGlowTimer
                    interval: 500
                    running: isActive && activeGlowFrames.length > 0
                    repeat: true
                    triggeredOnStart: true
                    onRunningChanged: {
                        if (running) {
                            activeGlowFrameIndex = 0
                            useAlternateActiveGlowFrame = false
                            activeGlowPrimaryTargetOpacity = 0.45
                            activeGlowSecondaryTargetOpacity = 0.0
                            activeGlowPrimaryScaleBoost = 1.05 + Math.random() * 0.05
                            activeGlowSecondaryScaleBoost = activeGlowPrimaryScaleBoost

                            var initialActiveGlowSource = activeGlowFrames[activeGlowFrameIndex]
                            activeGlowPrimarySource = initialActiveGlowSource
                            activeGlowSecondarySource = initialActiveGlowSource
                            activeGlowFramePrimary.opacity = activeGlowPrimaryTargetOpacity
                            activeGlowFrameSecondary.opacity = activeGlowSecondaryTargetOpacity
                        } else {
                            activeGlowFramePrimary.opacity = 0.0
                            activeGlowFrameSecondary.opacity = 0.0
                        }
                    }
                    onTriggered: {
                        activeGlowFrameIndex = (activeGlowFrameIndex + 1) % activeGlowFrames.length
                        var nextActiveGlowScaleBoost = 1.05 + Math.random() * 0.05

                        if (useAlternateActiveGlowFrame) {
                            activeGlowPrimarySource = activeGlowFrames[activeGlowFrameIndex]
                            activeGlowPrimaryScaleBoost = nextActiveGlowScaleBoost
                            activeGlowPrimaryTargetOpacity = 0.45
                            activeGlowSecondaryTargetOpacity = 0.0
                        } else {
                            activeGlowSecondarySource = activeGlowFrames[activeGlowFrameIndex]
                            activeGlowSecondaryScaleBoost = nextActiveGlowScaleBoost
                            activeGlowPrimaryTargetOpacity = 0.0
                            activeGlowSecondaryTargetOpacity = 0.45
                        }

                        activeGlowFramePrimary.opacity = activeGlowPrimaryTargetOpacity
                        activeGlowFrameSecondary.opacity = activeGlowSecondaryTargetOpacity
                        useAlternateActiveGlowFrame = !useAlternateActiveGlowFrame
                    }
                }
            }

            Behavior on activeGlowOpacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
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
                opacity: Math.min(1, statusDim + incapacitatedDim)
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation { duration: 240; easing.type: Easing.OutQuad }
                }
            }

            Item {
                id: statusOverlays
                anchors.fill: parent
                anchors.margins: overlayInset
                z: 4
                visible: concentrationActive || (tempHpValue > 0 && !tempIncapActive && tempIncapFrameIndex < 0)

                Image {
                    id: concentrationFramePrimary
                    anchors.fill: parent
                    anchors.rightMargin: overlayRightTrim
                    source: concentrationPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationActive && !concentrationTempActive
                    opacity: 1.0
                    transform: Scale { xScale: overlayScaleX; yScale: overlayScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: concentrationFrameSecondary
                    anchors.fill: parent
                    anchors.rightMargin: overlayRightTrim
                    source: concentrationSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationActive && !concentrationTempActive
                    opacity: 0.0
                    transform: Scale { xScale: overlayScaleX; yScale: overlayScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: tempHpFramePrimary
                    anchors.fill: parent
                    anchors.rightMargin: overlayRightTrim
                    source: tempHpPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: tempHpValue > 0 && !concentrationTempActive && !tempIncapActive && tempIncapFrameIndex < 0
                    opacity: 1.0
                    transform: Scale { xScale: tempHpScaleX; yScale: tempHpScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: tempHpFrameSecondary
                    anchors.fill: parent
                    anchors.rightMargin: overlayRightTrim
                    source: tempHpSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: tempHpValue > 0 && !concentrationTempActive && !tempIncapActive && tempIncapFrameIndex < 0
                    opacity: 0.0
                    transform: Scale { xScale: tempHpScaleX; yScale: tempHpScaleY; origin.x: width / 2; origin.y: height / 2 }
                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: concentrationTempFramePrimary
                    anchors.fill: parent
                    anchors.rightMargin: overlayRightTrim
                    source: concentrationTempPrimarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationTempActive
                    opacity: 1.0
                    transform: Scale {
                        xScale: (concentrationCanvasWidth / concentrationTempTargetFrameWidth) * (concentrationTempTargetFrameWidth / concentrationTempFrameWidths[concentrationTempPrimaryFrameMetaIndex])
                        yScale: (concentrationCanvasHeight / concentrationTempTargetFrameHeight) * (concentrationTempTargetFrameHeight / concentrationTempFrameHeights[concentrationTempPrimaryFrameMetaIndex])
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                Image {
                    id: concentrationTempFrameSecondary
                    anchors.fill: parent
                    anchors.rightMargin: overlayRightTrim
                    source: concentrationTempSecondarySource
                    fillMode: Image.Stretch
                    smooth: true
                    visible: concentrationTempActive
                    opacity: 0.0
                    transform: Scale {
                        xScale: (concentrationCanvasWidth / concentrationTempTargetFrameWidth) * (concentrationTempTargetFrameWidth / concentrationTempFrameWidths[concentrationTempSecondaryFrameMetaIndex])
                        yScale: (concentrationCanvasHeight / concentrationTempTargetFrameHeight) * (concentrationTempTargetFrameHeight / concentrationTempFrameHeights[concentrationTempSecondaryFrameMetaIndex])
                        origin.x: width / 2
                        origin.y: height / 2
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                Timer {
                    id: concentrationTempTimer
                    interval: 1000
                    running: concentrationTempActive && concentrationTempFrames.length > 0
                    repeat: true
                    triggeredOnStart: true
                    onRunningChanged: {
                        if (running) {
                            concentrationTempFrameIndex = 0
                            useAlternateConcentrationTempFrame = false
                            concentrationTempFramePrimary.opacity = 1.0
                            concentrationTempFrameSecondary.opacity = 0.0
                            concentrationTempPrimaryTargetOpacity = 1.0
                            concentrationTempSecondaryTargetOpacity = 0.0
                            var initialConcentrationTempSource = concentrationTempFrames[concentrationTempFrameIndex]
                            if (concentrationTempPrimarySource !== initialConcentrationTempSource) {
                                concentrationTempPrimarySource = initialConcentrationTempSource
                            }
                            if (concentrationTempSecondarySource !== initialConcentrationTempSource) {
                                concentrationTempSecondarySource = initialConcentrationTempSource
                            }
                            concentrationTempPrimaryFrameMetaIndex = concentrationTempFrameIndex
                            concentrationTempSecondaryFrameMetaIndex = concentrationTempFrameIndex
                        }
                    }
                    onTriggered: {
                        concentrationTempFrameIndex = (concentrationTempFrameIndex + 1) % concentrationTempFrames.length
                        if (useAlternateConcentrationTempFrame) {
                            concentrationTempPrimarySource = concentrationTempFrames[concentrationTempFrameIndex]
                            concentrationTempPrimaryFrameMetaIndex = concentrationTempFrameIndex
                            concentrationTempPrimaryTargetOpacity = 1.0
                            concentrationTempSecondaryTargetOpacity = 0.0
                        } else {
                            concentrationTempSecondarySource = concentrationTempFrames[concentrationTempFrameIndex]
                            concentrationTempSecondaryFrameMetaIndex = concentrationTempFrameIndex
                            concentrationTempPrimaryTargetOpacity = 0.0
                            concentrationTempSecondaryTargetOpacity = 1.0
                        }
                        concentrationTempFramePrimary.opacity = concentrationTempPrimaryTargetOpacity
                        concentrationTempFrameSecondary.opacity = concentrationTempSecondaryTargetOpacity
                        useAlternateConcentrationTempFrame = !useAlternateConcentrationTempFrame
                    }
                }

                Timer {
                    id: tempHpTimer
                    interval: 1000
                    running: tempHpValue > 0 && tempHpFrames.length > 0 && !tempIncapActive && tempIncapFrameIndex < 0
                    repeat: true
                    triggeredOnStart: true
                    onRunningChanged: {
                        if (running) {
                            tempHpFrameIndex = 0
                            useAlternateTempHpFrame = false
                            tempHpFramePrimary.opacity = 1.0
                            tempHpFrameSecondary.opacity = 0.0
                            tempHpPrimaryTargetOpacity = 1.0
                            tempHpSecondaryTargetOpacity = 0.0
                            var initialTempHpSource = tempHpFrames[tempHpFrameIndex]
                            if (tempHpPrimarySource !== initialTempHpSource) {
                                tempHpPrimarySource = initialTempHpSource
                            }
                            if (tempHpSecondarySource !== initialTempHpSource) {
                                tempHpSecondarySource = initialTempHpSource
                            }
                        }
                    }
                    onTriggered: {
                        tempHpFrameIndex = (tempHpFrameIndex + 1) % tempHpFrames.length
                        if (useAlternateTempHpFrame) {
                            tempHpPrimarySource = tempHpFrames[tempHpFrameIndex]
                            tempHpPrimaryTargetOpacity = 1.0
                            tempHpSecondaryTargetOpacity = 0.0
                        } else {
                            tempHpSecondarySource = tempHpFrames[tempHpFrameIndex]
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
                    interval: 1000
                    running: concentrationActive && concentrationFrames.length > 0
                    repeat: true
                    triggeredOnStart: true
                    onRunningChanged: {
                        if (running) {
                            concentrationFrameIndex = 0
                            useAlternateFrame = false
                            concentrationFramePrimary.opacity = 1.0
                            concentrationFrameSecondary.opacity = 0.0
                            primaryTargetOpacity = 1.0
                            secondaryTargetOpacity = 0.0
                            var initialConcentrationSource = concentrationFrames[concentrationFrameIndex]
                            if (concentrationPrimarySource !== initialConcentrationSource) {
                                concentrationPrimarySource = initialConcentrationSource
                            }
                            if (concentrationSecondarySource !== initialConcentrationSource) {
                                concentrationSecondarySource = initialConcentrationSource
                            }
                        }
                    }
                    onTriggered: {
                        concentrationFrameIndex = (concentrationFrameIndex + 1) % concentrationFrames.length
                        if (useAlternateFrame) {
                            concentrationPrimarySource = concentrationFrames[concentrationFrameIndex]
                            primaryTargetOpacity = 1.0
                            secondaryTargetOpacity = 0.0
                        } else {
                            concentrationSecondarySource = concentrationFrames[concentrationFrameIndex]
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
                        NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
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
                id: contentArea
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.bottomMargin: 12
                anchors.topMargin: statusBar.height + 16

                Text {
                    id: nameText
                    text: displayName
                    color: inkLight
                    font.pixelSize: 20
                    font.family: pixelFont.name
                    elide: Text.ElideRight
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    z: 3
                }

                Rectangle {
                    id: smokeOverlay
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: nameText.bottom
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
                    anchors.top: nameText.bottom
                    anchors.bottom: parent.bottom
                    spacing: 8

                    Row {
                        spacing: 8
                        visible: showHpText
                        Text {
                            text: hp === null ? "HP —" : ("HP " + hp + " / " + max_hp)
                            color: inkMuted
                            font.pixelSize: 16
                            font.family: pixelFont.name
                        }
                        Text {
                            text: tempHpValue > 0 ? ("+ " + tempHpValue) : ""
                            color: accentCool
                            font.pixelSize: 14
                            font.family: pixelFont.name
                            visible: tempHpValue > 0
                        }
                    }

                    Rectangle {
                        id: hpBar
                        height: 12
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

                    Flow {
                        spacing: 6
                        width: parent.width
                        visible: !stateValue || stateValue === "alive"
                        Repeater {
                            model: visibleEffects
                            delegate: Rectangle {
                                radius: 0
                                color: modelData.indexOf("Временные") === 0 ? "#243E55" : modelData.indexOf("Конц") === 0 ? "#34244A" : modelData.indexOf("Недеесп") === 0 ? "#3F2A1D" : (modelData.indexOf("Отрав") === 0 || modelData.indexOf("Яд") === 0) ? "#263A1A" : panelDark
                                border.width: 1
                                border.color: (modelData.indexOf("Отрав") === 0 || modelData.indexOf("Яд") === 0) ? accentPoison : panelEdge
                                height: 20
                                implicitWidth: chipText.implicitWidth + 12
                                opacity: 0.0
                                SequentialAnimation on opacity {
                                    running: true
                                    NumberAnimation { from: 0.0; to: 1.0; duration: 220; easing.type: Easing.OutQuad }
                                }
                                Text {
                                    id: chipText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: (modelData.indexOf("Отрав") === 0 || modelData.indexOf("Яд") === 0) ? accentPoison : inkSoft
                                    font.pixelSize: 12
                                    font.family: pixelFont.name
                                }
                            }
                        }
                    }
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
                lastTempHp = tempHpValue
            }

            onTempIncapActiveChanged: {
                if (lastTempIncapActive === tempIncapActive) {
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
                if (lastConcentration === concentrationActive) {
                    return
                }
                if (concentrationActive) {
                    concentrationFrameIndex = 0
                }
                lastConcentration = concentrationActive
            }

            onIncapacitatedActiveChanged: {
                if (lastIncapacitated === incapacitatedActive) {
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

            onStateValueChanged: {
                if (lastState === stateValue) {
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
                interval: 600
                repeat: false
                onTriggered: {
                    if (pendingStateVisual) {
                        applyStateVisuals(pendingStateVisual)
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
