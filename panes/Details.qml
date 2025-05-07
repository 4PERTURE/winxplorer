import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import io.gitgud.catpswin56.private.filesmodel

Item {
    id: detailsPane

    property alias updateDetailsIcon: updateDetailsIcon

    implicitHeight: 70

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 1.0; color: "#bbd9f0" }
            GradientStop { position: 0.0; color: "#f3fbfe" }
        }
    }

    BorderImage {
        anchors.fill: parent

        border {
            top: 6
            bottom: 0
            left: 1
            right: 1
        }
        source: "qrc:/aero/detailsShadow.png"
    }

    Row {
        spacing: 15

        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: 4
            right: parent.right
            rightMargin: 4
        }

        Kirigami.Icon {
            id: icon

            width: 64
            height: width

            Timer {
                id: updateDetailsIcon

                interval: 50
                onTriggered: icon.source = FilesModel.currentDirIcon
            }
        }

        Text {
            anchors.top: parent.top

            text: innerContents.filesPane.count + " items"
            font.pointSize: 10
        }
    }
}
