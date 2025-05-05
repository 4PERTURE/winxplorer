import QtQuick
import QtQuick.Layouts

import Controls as Controls

Item {
    id: commandBar

    implicitHeight: 32

    ListModel {
        id: commandModel

        ListElement {
            title: "Organize"
            icon: "application-menu"
        }

        ListElement {
            title: "Views"
            icon: "view-list-tree"
        }

        ListElement {
            title: "Properties"
            icon: "document-properties"
        }
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 1.0; color: "#196c77" }
            GradientStop { position: 0.0; color: "#044875" }
        }
    }
    BorderImage {
        anchors.fill: parent
        border {
            top: 1
            bottom: 2
            right: 1
            left: 1
        }
        source: "qrc:/aero/commandBar/shine.png"
    }

    RowLayout {
        anchors.fill: parent
        anchors.rightMargin: 3
        anchors.leftMargin: 3

        Repeater {
            model: commandModel
            delegate: Controls.CommandButton {  }
        }

        Item { Layout.fillWidth: true }

        Controls.CommandButton {
            model: {
                "title": "",
                "icon": "browser-help"
            }
        }
    }
}
