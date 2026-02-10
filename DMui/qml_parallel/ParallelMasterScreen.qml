import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"

ApplicationWindow {
    id: root
    width: 1600
    height: 960
    visible: true
    title: "DM UI - QML Parallel"
    color: "#120D16"

    property var selectedMap: ({})

    property var bridge: (typeof dmBridge !== "undefined" ? dmBridge : null)

    function safeText(value, fallback) {
        return value === null || value === undefined ? fallback : value
    }

    function safeCombatants() {
        return bridge && bridge.combatants ? bridge.combatants : []
    }

    function selectedIndexes() {
        const values = []
        for (let key in selectedMap) {
            if (selectedMap[key]) {
                values.push(parseInt(key))
            }
        }
        return values
    }

    function toggleSelection(index, checked) {
        selectedMap[index] = checked
    }

    Connections {
        target: bridge
        function onStateChanged() {
            participantsView.model = safeCombatants()
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1A1220" }
            GradientStop { position: 1.0; color: "#0D0911" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: 8
            color: "#2D2130"
            border.color: "#654A4B"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 18

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Хроника"
                        color: "#EFE3D2"
                        font.pixelSize: 36
                        font.bold: true
                    }

                    Text {
                        text: safeText(bridge ? bridge.roundText : null, "Раунд: —")
                        color: "#DBC0A0"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }

                Text {
                    text: safeText(bridge ? bridge.battleStateText : null, "Состояние: —")
                    color: "#F4DEC6"
                    font.pixelSize: 28
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            ColumnLayout {
                Layout.preferredWidth: 560
                Layout.fillHeight: true
                spacing: 12

                SectionCard {
                    title: "Управление боем"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ThemedButton { text: "Начать бой"; onClicked: if (bridge) bridge.startBattle() }
                        ThemedButton { text: "Следующий ход"; onClicked: if (bridge) bridge.nextTurn() }
                        ThemedButton { text: "Завершить бой"; onClicked: if (bridge) bridge.endBattle() }
                    }

                    Text {
                        text: safeText(bridge ? bridge.statusMessage : null, "")
                        color: "#BCA38E"
                        font.pixelSize: 14
                    }
                }

                SectionCard {
                    title: "Добавление игрока"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150

                    RowLayout {
                        Layout.fillWidth: true
                        TextField { id: playerName; placeholderText: "Имя игрока"; Layout.fillWidth: true }
                        TextField { id: playerInitiative; placeholderText: "Инициатива"; Layout.preferredWidth: 120 }
                        ThemedButton {
                            text: "Добавить"
                            onClicked: {
                                if (bridge) bridge.addPlayer(playerName.text, playerInitiative.text)
                                playerName.text = ""
                                playerInitiative.text = ""
                            }
                        }
                    }
                }

                SectionCard {
                    title: "Добавление монстров"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 8
                        rowSpacing: 8

                        TextField { id: monsterName; placeholderText: "Название"; Layout.columnSpan: 2; Layout.fillWidth: true }
                        SpinBox { id: monsterCount; from: 1; to: 99; value: 1 }

                        TextField { id: customName; placeholderText: "Кастомное имя"; Layout.fillWidth: true }
                        TextField { id: monsterHp; placeholderText: "HP"; Layout.fillWidth: true }
                        TextField { id: monsterAc; placeholderText: "AC"; Layout.fillWidth: true }

                        TextField { id: monsterInitiative; placeholderText: "Инициатива"; Layout.fillWidth: true }
                        Item { Layout.fillWidth: true }
                        ThemedButton {
                            text: "Добавить"
                            onClicked: {
                                if (bridge) bridge.addMonsters(monsterName.text, monsterCount.value, customName.text, monsterHp.text, monsterAc.text, monsterInitiative.text)
                                monsterName.text = ""
                                customName.text = ""
                                monsterHp.text = ""
                                monsterAc.text = ""
                                monsterInitiative.text = ""
                                monsterCount.value = 1
                            }
                        }
                    }
                }

                SectionCard {
                    title: "Эффекты и действия"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        rowSpacing: 8
                        columnSpacing: 8

                        TextField { id: effectName; placeholderText: "Эффект"; Layout.fillWidth: true; Layout.columnSpan: 2 }
                        SpinBox { id: effectDuration; from: 0; to: 999; value: 0 }
                        ThemedButton { text: "Добавить эффект"; onClicked: if (bridge) bridge.addEffect(selectedIndexes(), effectName.text, effectDuration.value) }

                        TextField { id: removeEffectName; placeholderText: "Эффект для удаления"; Layout.fillWidth: true; Layout.columnSpan: 3 }
                        ThemedButton { text: "Убрать"; onClicked: if (bridge) bridge.removeEffect(selectedIndexes(), removeEffectName.text) }

                        SpinBox { id: dmgAmount; from: 1; to: 999; value: 1 }
                        ThemedButton { text: "Урон"; onClicked: if (bridge) bridge.applyDamage(selectedIndexes(), dmgAmount.value) }
                        SpinBox { id: healAmount; from: 1; to: 999; value: 1 }
                        ThemedButton { text: "Лечение"; onClicked: if (bridge) bridge.applyHeal(selectedIndexes(), healAmount.value) }

                        SpinBox { id: tempAmount; from: 0; to: 999; value: 0 }
                        ThemedButton { text: "Временные HP"; onClicked: if (bridge) bridge.setTempHp(selectedIndexes(), tempAmount.value); Layout.columnSpan: 3 }
                    }
                }
            }

            SectionCard {
                title: "Участники"
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: participantsView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: safeCombatants()

                    delegate: Rectangle {
                        required property var modelData
                        width: participantsView.width
                        height: 120
                        radius: 8
                        color: modelData.isCurrent ? "#4E3E2F" : "#221722"
                        border.color: modelData.isCurrent ? "#F2DFA2" : "#5F484C"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true

                                CheckBox {
                                    checked: root.selectedMap[modelData.index] === true
                                    onToggled: root.toggleSelection(modelData.index, checked)
                                }

                                Text {
                                    text: modelData.name + " (ИНИ " + modelData.initiative + ")"
                                    color: "#F8E8D3"
                                    font.pixelSize: 18
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                ComboBox {
                                    model: ["Жив", "Без сознания", "Мертв", "Покинул бой"]
                                    currentIndex: model.indexOf(modelData.state)
                                    onActivated: if (bridge) bridge.setState(modelData.index, currentText)
                                    Layout.preferredWidth: 180
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text { text: "HP: " + modelData.hp + " (Temp: " + modelData.tempHp + ")"; color: "#9EE68E" }
                                Text { text: "AC: " + modelData.ac; color: "#D9CAB5" }
                                Text { text: "Эффекты: " + modelData.effects; color: "#C8A8D7"; Layout.fillWidth: true; elide: Text.ElideRight }

                                CheckBox {
                                    text: "Конц."
                                    checked: modelData.concentration
                                    onToggled: if (bridge) bridge.setConcentration(modelData.index, checked)
                                }
                                CheckBox {
                                    text: "Недеесп."
                                    checked: modelData.incapacitated
                                    onToggled: if (bridge) bridge.setIncapacitated(modelData.index, checked)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
