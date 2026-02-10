import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property alias content: contentItem.data
    property string title: ""
    property color panelColor: "#241822"

    radius: 10
    color: panelColor
    border.color: "#634C47"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            height: 30
            radius: 5
            color: "#3A2C37"
            border.color: "#6A5352"

            Text {
                anchors.centerIn: parent
                text: root.title
                color: "#F4E6D2"
                font.pixelSize: 15
                font.bold: true
            }
        }

        ColumnLayout {
            id: contentItem
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
        }
    }
}
