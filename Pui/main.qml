import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: root
    width: 1920
    height: 1080
    visible: true
    title: "Player UI"
    color: "#251d14"

    FontLoader {
        id: pixelFont
        source: "fonts/8bitoperatorJVE.ttf"
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
    property color inkLight: "#f8f1de"
    property color inkMuted: "#d9c8a6"
    property color inkSoft: "#b9a581"
    property color panelDark: "#3a2f22"
    property color panelMid: "#4a3a2a"
    property color panelEdge: "#6a5642"
    property color accentWarm: "#e5c874"
    property color accentBright: "#ffe6a6"
    property color accentCool: "#a6d3ff"
    property color accentViolet: "#b49add"
    property color accentSmoke: "#3b3126"
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
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#2c2319" }
            GradientStop { position: 0.55; color: "#2a2218" }
            GradientStop { position: 1.0; color: "#201a12" }
        }
    }

    Column {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10
        padding: 24

        Row {
            spacing: 14
            Rectangle {
                id: sigil
                width: 40
                height: 40
                radius: 8
                color: panelDark
                border.width: 1
                border.color: panelEdge

                Rectangle {
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                    radius: 6
                    color: "#2a231c"
                    border.width: 1
                    border.color: accentWarm
                    rotation: sigilSpin.rotation

                    RotationAnimator on rotation {
                        id: sigilSpin
                        from: 0
                        to: 360
                        duration: 2400
                        loops: Animation.Infinite
                        running: true
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "⟲"
                        color: accentBright
                        font.pixelSize: 16
                        font.family: pixelFont.name
                    }
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
                    color: (playerState && playerState.running) ? accentBright : inkSoft
                    font.pixelSize: 18
                    font.family: pixelFont.name
                }
            }

            Rectangle {
                width: 1
                height: 34
                color: panelEdge
                opacity: 0.6
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: (playerState && playerState.running) ? "Бой идет" : "Тишина"
                color: inkMuted
                font.pixelSize: 16
                font.family: pixelFont.name
                anchors.verticalCenter: parent.verticalCenter
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
            radius: 10
            color: panelMid
            border.width: isActive ? 2 : 1
            border.color: isActive ? accentWarm : panelEdge

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
            property string stateValue: state
            property int tempHpValue: temp_hp
            property string lastState: stateValue
            property var lastTempHp: tempHpValue
            property int maxEffects: 6
            property var effectList: {
                var list = []
                if (effects) {
                    if (effects.list && effects.list.length) {
                        list = effects.list.slice(0)
                    } else {
                        if (effects.temp_hp) list.push("Временные HP")
                        if (effects.concentration) list.push("Концентрация")
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
                    var remaining = effectList.length - (maxEffects - 1)
                    return effectList.slice(0, maxEffects - 1).concat(["+" + remaining])
                }
                return effectList
            }

            transform: [
                Translate { x: shakeOffset; y: liftOffset }
            ]

            Rectangle {
                id: statusBar
                height: 28
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                radius: 6
                color: isActive ? accentWarm : panelDark
                border.width: 1
                border.color: isActive ? accentBright : panelEdge
                scale: statusPulse.scale

                Text {
                    anchors.centerIn: parent
                    text: isActive ? "ХОДИТ" : (stateValue === "dead" ? "МЕРТВ" : stateValue === "unconscious" ? "БЕЗ СОЗН." : stateValue === "left" ? "ПОКИНУЛ" : "ГОТОВ")
                    color: isActive ? "#1d1407" : inkMuted
                    font.pixelSize: 13
                    font.family: pixelFont.name
                }
            }

            SequentialAnimation {
                id: statusPulse
                property real scale: 1
                running: false
                NumberAnimation { target: statusPulse; property: "scale"; from: 1; to: 1.05; duration: 120; easing.type: Easing.OutQuad }
                NumberAnimation { target: statusPulse; property: "scale"; to: 1; duration: 220; easing.type: Easing.OutQuad }
            }

            Rectangle {
                id: activeGlow
                anchors.fill: parent
                radius: 12
                color: accentBright
                opacity: 0.0
                visible: isActive
                z: -1
                SequentialAnimation on opacity {
                    running: isActive
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.0; to: 0.18; duration: 700; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.18; to: 0.0; duration: 700; easing.type: Easing.InOutQuad }
                }
            }

            Rectangle {
                id: flashOverlay
                anchors.fill: parent
                radius: 10
                color: flashColor
                opacity: 0.0
                visible: opacity > 0
            }

            Rectangle {
                id: statusFlash
                anchors.fill: parent
                radius: 10
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
                radius: 10
                color: "#1f170f"
                opacity: statusDim
                visible: statusDim > 0
            }

            Rectangle {
                id: unconsciousPulse
                anchors.fill: parent
                radius: 10
                color: "#2a241d"
                visible: stateValue === "unconscious"
                opacity: stateValue === "unconscious" ? (0.18 + 0.12 * (Math.max(0, Math.sin(root.heartbeatPhase)) + 0.6 * Math.max(0, Math.sin(root.heartbeatPhase * 2.2 - 0.6)))) : 0
            }

            Item {
                id: contentArea
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: statusBar.bottom
                anchors.bottom: parent.bottom
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.bottomMargin: 12
                anchors.topMargin: 8

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
                        radius: 2
                        visible: showHpBar
                        color: panelDark
                        border.width: 1
                        border.color: panelEdge
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Rectangle {
                            id: hpLossTrail
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            radius: 0
                            color: "#f2e7d0"
                            opacity: 0.0
                        }

                        Rectangle {
                            id: hpFill
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * hpRatio
                            radius: 0
                            color: hpRatio > 0.5 ? "#76c07a" : hpRatio > 0.2 ? "#d9b45a" : "#c46856"
                            Behavior on width {
                                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                            }
                        }

                        Rectangle {
                            id: tempHpFill
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: tempHpValue > 0 ? Math.min(parent.width * 0.25, parent.width * (tempHpValue / (max_hp || 1))) : 0
                            radius: 0
                            color: "#8aa2b8"
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
                                    color: "#9ab0c4"
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
                        id: concentrationField
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 18
                        visible: effects && effects.concentration

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.9
                            height: 2
                            color: accentViolet
                            opacity: 0.0
                            rotation: 12
                            SequentialAnimation on opacity {
                                running: concentrationField.visible
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.0; to: 0.6; duration: 900; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 0.6; to: 0.0; duration: 900; easing.type: Easing.InOutQuad }
                            }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.85
                            height: 2
                            color: accentViolet
                            opacity: 0.0
                            rotation: -12
                            SequentialAnimation on opacity {
                                running: concentrationField.visible
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.0; to: 0.45; duration: 900; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 0.45; to: 0.0; duration: 900; easing.type: Easing.InOutQuad }
                            }
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
                                color: modelData.indexOf("Временные") === 0 ? "#354150" : modelData.indexOf("Конц") === 0 ? "#3b2e4a" : modelData.indexOf("Недеесп") === 0 ? "#3d3326" : panelDark
                                border.width: 1
                                border.color: panelEdge
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
                                    color: inkSoft
                                    font.pixelSize: 12
                                    font.family: pixelFont.name
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: stateValue === "dead" ? "Мертв" :
                      stateValue === "unconscious" ? "Без сознания" :
                      stateValue === "left" ? "Покинул бой" : ""
                color: inkLight
                font.pixelSize: 20
                font.family: pixelFont.name
                visible: stateValue !== "alive"
            }

            onIsActiveChanged: {
                statusPulse.restart()
            }

            onHpValueChanged: {
                if (hpValue === null || lastHp === null || hpValue === undefined || lastHp === undefined) {
                    lastHp = hpValue
                    lastHpRatio = hpRatio
                    return
                }
                if (hpValue < lastHp) {
                    flashColor = "#b84a3a"
                    flashPeak = 0.35
                    flashAnim.restart()
                    shakeAnim.restart()
                    hpLossTrail.x = hpBar.width * hpRatio
                    hpLossTrail.width = Math.max(0, hpBar.width * (lastHpRatio - hpRatio))
                    hpLossTrail.opacity = 0.7
                    hpLossTrailAnimation.restart()
                } else if (hpValue > lastHp) {
                    flashColor = "#4fa96f"
                    flashPeak = 0.28
                    flashAnim.restart()
                    liftAnim.restart()
                }
                lastHp = hpValue
                lastHpRatio = hpRatio
            }

            SequentialAnimation {
                id: hpLossTrailAnimation
                running: false
                PropertyAnimation { target: hpLossTrail; property: "opacity"; from: 0.7; to: 0.0; duration: 120; easing.type: Easing.OutQuad }
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
                lastTempHp = tempHpValue
            }

            SequentialAnimation {
                id: tempHpAppear
                running: false
                PropertyAnimation { target: tempHpFill; property: "opacity"; from: 0.0; to: 1.0; duration: 120; easing.type: Easing.OutQuad }
            }

            onStateValueChanged: {
                if (lastState === stateValue) {
                    return
                }
                if (stateValue === "dead") {
                    statusFlashColor = "#c4574a"
                    statusFlashPeak = 0.45
                    statusFlashAnim.restart()
                    statusDim = 0.7
                } else if (stateValue === "unconscious") {
                    statusFlashColor = "#c46b55"
                    statusFlashPeak = 0.32
                    statusFlashAnim.restart()
                    statusDim = 0.55
                } else if (stateValue === "left") {
                    smokeFadeIn.restart()
                    statusDim = 0.3
                } else if (stateValue === "alive") {
                    if (lastState === "dead" || lastState === "unconscious") {
                        statusFlashColor = "#e8d26f"
                        statusFlashPeak = 0.4
                        statusFlashAnim.restart()
                        liftAnim.restart()
                    }
                    if (lastState === "left") {
                        smokeFadeOut.restart()
                    }
                    statusDim = 0
                }
                lastState = stateValue
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
