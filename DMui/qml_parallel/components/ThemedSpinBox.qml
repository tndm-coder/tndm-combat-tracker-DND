import QtQuick 2.15
import QtQuick.Controls 2.15

SpinBox {
    id: control
    implicitHeight: 34
    from: 0
    to: 999
    editable: true
    font.pixelSize: 14

    validator: IntValidator {
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    contentItem: TextInput {
        z: 2
        text: control.displayText
        font: control.font
        color: "#EEDFCC"
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        selectByMouse: true
        leftPadding: 6
        rightPadding: 6

        onTextEdited: control.value = Number.fromLocaleString(control.locale, text)
    }

    up.indicator: Rectangle {
        implicitWidth: 28
        implicitHeight: 34
        x: control.width - width
        color: control.up.pressed ? "#47363E" : "#3B2D34"
        border.color: "#6E5553"

        Text {
            text: "+"
            anchors.centerIn: parent
            color: "#EEDFCC"
            font.pixelSize: 18
        }
    }

    down.indicator: Rectangle {
        implicitWidth: 28
        implicitHeight: 34
        x: 0
        color: control.down.pressed ? "#47363E" : "#3B2D34"
        border.color: "#6E5553"

        Text {
            text: "−"
            anchors.centerIn: parent
            color: "#EEDFCC"
            font.pixelSize: 18
        }
    }

    background: Rectangle {
        color: "#2C2028"
        radius: 5
        border.color: control.activeFocus ? "#9B7767" : "#6E5553"
        border.width: 1
    }
}
