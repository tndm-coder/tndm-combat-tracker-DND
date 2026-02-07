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
        source: "fonts/MyFont.ttf"
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
        spacing: 6
        padding: 24

        Row {
            spacing: 12
            Text {
                text: "⚔️ Бой"
                color: inkLight
                font.pixelSize: 26
                font.family: pixelFont.name
            }
            Rectangle {
                width: 1
                height: 20
                color: panelEdge
                opacity: 0.7
            }
            Text {
                text: (playerState && playerState.running) ? ("Раунд " + playerState.round) : "Ожидание боя"
                color: (playerState && playerState.running) ? accentBright : inkSoft
                font.pixelSize: 18
                font.family: pixelFont.name
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
        border.width: is_active ? 2 : 1
        border.color: is_active ? accentWarm : panelEdge

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
        property var lastHp: hpValue
        property color flashColor: "transparent"
        property real flashPeak: 0.35

        Rectangle {
            id: statusBar
            height: 26
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            radius: 6
            color: is_active ? accentWarm : panelDark
            border.width: 1
            border.color: is_active ? accentBright : panelEdge

            Text {
                anchors.centerIn: parent
                text: is_active ? "ХОД" : "ГОТОВ"
                color: is_active ? "#1d1407" : inkMuted
                font.pixelSize: 14
                font.family: pixelFont.name
            }
        }

        Rectangle {
            id: activeGlow
            anchors.fill: parent
            radius: 12
            color: accentBright
            opacity: 0.0
            visible: is_active
            z: -1
            SequentialAnimation on opacity {
                running: is_active
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
                duration: 380
                easing.type: Easing.OutQuad
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: statusBar.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.bottomMargin: 12
            anchors.topMargin: 8
            spacing: 8

            Text {
                text: displayName
                color: inkLight
                font.pixelSize: 20
                font.family: pixelFont.name
                elide: Text.ElideRight
            }

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
                    text: temp_hp > 0 ? ("+ " + temp_hp) : ""
                    color: accentCool
                    font.pixelSize: 14
                    font.family: pixelFont.name
                    visible: temp_hp > 0
                }
            }

            Rectangle {
                height: 12
                radius: 4
                visible: showHpBar
                color: panelDark
                border.width: 1
                border.color: panelEdge
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    id: hpFill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * hpRatio
                    radius: 4
                    color: hpRatio > 0.5 ? "#76c07a" : hpRatio > 0.2 ? "#d9b45a" : "#c46856"
                    Behavior on width {
                        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                    }
                }

                Rectangle {
                    id: tempHpFill
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: temp_hp > 0 ? Math.min(parent.width * 0.2, parent.width * (temp_hp / (max_hp || 1))) : 0
                    radius: 4
                    color: "#7cb6e6"
                    visible: temp_hp > 0
                    Behavior on width {
                        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                    }
                }
            }

            Row {
                spacing: 6
                visible: !state || state === "alive"
                Repeater {
                    model: [
                        effects && effects.temp_hp ? "Временные HP" : "",
                        effects && effects.concentration ? "Конц." : "",
                        effects && effects.incapacitated ? "Недеесп." : ""
                    ].filter(function(item) { return item.length > 0 })
                    delegate: Rectangle {
                        radius: 4
                        color: panelDark
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

        Rectangle {
            anchors.fill: parent
            color: "#1f170f"
            opacity: 0.5
            visible: state !== "alive"
        }

        Text {
            anchors.centerIn: parent
            text: state === "dead" ? "Мертв" :
                  state === "unconscious" ? "Без сознания" :
                  state === "left" ? "Покинул бой" : ""
            color: inkLight
            font.pixelSize: 20
            font.family: pixelFont.name
            visible: state !== "alive"
        }

        onHpValueChanged: {
            if (hpValue === null || lastHp === null || hpValue === undefined || lastHp === undefined) {
                lastHp = hpValue
                return
            }
            if (hpValue < lastHp) {
                flashColor = "#b84a3a"
                flashPeak = 0.35
                flashAnim.restart()
            } else if (hpValue > lastHp) {
                flashColor = "#4fa96f"
                flashPeak = 0.28
                flashAnim.restart()
            }
            lastHp = hpValue
        }
    }
    }
}
