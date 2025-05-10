import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    id: detailsPane

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
        source: "qrc:/aero/misc/detailsShadow.png"
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

            source: filesModel.currentDirIcon
        }

        Text {
            anchors.top: parent.top

            text: innerContents.filesPane.count + " items"
            font.pointSize: 10
        }
    }
}
