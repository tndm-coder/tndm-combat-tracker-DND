import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: root
    implicitHeight: 34
    padding: 10
    color: "#EEDFCC"
    placeholderTextColor: "#9F8572"
    selectedTextColor: "#251A20"
    selectionColor: "#D6B898"
    font.pixelSize: 14

    background: Rectangle {
        radius: 5
        color: "#2C2028"
        border.color: root.activeFocus ? "#9B7767" : "#6E5553"
        border.width: 1
    }
}
