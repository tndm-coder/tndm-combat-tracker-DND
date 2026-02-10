import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: root

    contentItem: Text {
        text: root.text
        color: "#F7EAD8"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 6
        color: root.down ? "#46343C" : (root.hovered ? "#4E3A43" : "#3A2B34")
        border.color: "#735B5A"
        border.width: 1
    }
}
