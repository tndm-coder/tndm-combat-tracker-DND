import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: root
    width: 1920
    height: 1080
    visible: true
    title: "Player UI"
    color: "#0d0f14"

    property int columns: {
        var count = playerModel.count
        if (count <= 12) return 1
        if (count <= 30) return 2
        return 3
    }
    property int rowCount: {
        if (playerModel.count === 0) return 1
        return Math.ceil(playerModel.count / columns)
    }
    property int columnGap: 24
    property int rowGap: 14
    property int cardMinHeight: 68
    property int cardMaxHeight: 140
    property int cardHeight: {
        var usable = height - header.height - 40
        var candidate = Math.floor((usable - (rowCount - 1) * rowGap) / rowCount)
        return Math.max(cardMinHeight, Math.min(cardMaxHeight, candidate))
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0b0d12" }
            GradientStop { position: 1.0; color: "#141823" }
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
                color: "#f5f5f5"
                font.pixelSize: 26
            }
            Rectangle {
                width: 1
                height: 20
                color: "#2b3240"
                opacity: 0.7
            }
            Text {
                text: playerState.running ? ("Раунд " + playerState.round) : "Ожидание боя"
                color: playerState.running ? "#cdd8ff" : "#9aa3b5"
                font.pixelSize: 18
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
            color: "#1a1f2a"
            border.width: is_active ? 2 : 1
            border.color: is_active ? "#8cb8ff" : "#2c3340"

            Rectangle {
                width: 6
                height: parent.height
                color: is_active ? "#8cb8ff" : "transparent"
                radius: 10
                anchors.left: parent.left
            }

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
                    text: name
                    color: "#f2f5ff"
                    font.pixelSize: 20
                    elide: Text.ElideRight
                }

                Row {
                    spacing: 8
                    Text {
                        text: hp === null ? "HP —" : ("HP " + hp + " / " + max_hp)
                        color: "#cfd7e6"
                        font.pixelSize: 16
                    }
                    Text {
                        text: temp_hp > 0 ? ("+ " + temp_hp) : ""
                        color: "#9bd0ff"
                        font.pixelSize: 14
                        visible: temp_hp > 0
                    }
                }

                Row {
                    spacing: 8
                    visible: !state || state === "alive"
                    Repeater {
                        model: [
                            effects && effects.temp_hp ? "🛡️ Временные HP" : "",
                            effects && effects.concentration ? "✨ Конц." : "",
                            effects && effects.incapacitated ? "🌀 Недеесп." : ""
                        ].filter(function(item) { return item.length > 0 })
                        delegate: Text {
                            text: modelData
                            color: "#9aa8c8"
                            font.pixelSize: 13
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.5
                visible: state !== "alive"
            }

            Text {
                anchors.centerIn: parent
                text: state === "dead" ? "Мертв" :
                      state === "unconscious" ? "Без сознания" :
                      state === "left" ? "Покинул бой" : ""
                color: "#f2f5ff"
                font.pixelSize: 20
                visible: state !== "alive"
            }
        }
    }
}
