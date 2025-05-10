import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import org.kde.kirigami as Kirigami

MouseArea {
    id: controlRoot

    required property var model

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: 24

    hoverEnabled: true

    Item {
        id: contents

        anchors.fill: parent

        BorderImage {
            readonly property string state: {
                if(controlRoot.containsPress) return "pressed";
                return "hover";
            }

            anchors.fill: parent

            border {
                top: 3
                bottom: 3
                right: 3
                left: 3
            }

            source: "qrc:/aero/commandBar/btn-" + state + ".png"

            visible: controlRoot.containsMouse
        }

        RowLayout {
            id: contentRow

            anchors.fill: parent
            anchors.rightMargin: 6
            anchors.leftMargin: 6

            spacing: 2

            Kirigami.Icon {
                implicitWidth: 16
                implicitHeight: implicitWidth

                source: controlRoot.model.icon
            }

            Text {
                text: controlRoot.model.title
                color: "white"
                style: Text.Outline
                styleColor: "#00FFFFFF"

                visible: text !== ""

                // the multieffect shadow was bad :(
                Text {
                    anchors.fill: parent
                    anchors.topMargin: 1

                    text: parent.text
                    color: "black"
                    style: Text.Outline
                    styleColor: "#00000000"

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.3
                        brightness: -1.0
                        saturation: 1.0
                    }
                    z: -1
                }
            }

            Image {

            }
        }
    }
}
