import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    id: paneRoot

    Column {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right

            topMargin: 12
            rightMargin: 3
        }

        Text {
            text: "Favorite Links"
            opacity: 0.5
            leftPadding: 11
        }

        Item { width: 1; height: 10 }

        Text {
            text: "(Empty)"
            color: "#0066cc"
            leftPadding: 30

            visible: favoritesModel.count == 0
        }

        Repeater {
            model: favoritesModel
            delegate: MouseArea {
                id: favoritesRoot

                required property var model

                width: parent.width
                height: 22

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: favoritesModel.trigger(model.path)

                BorderImage {
                    readonly property string state: {
                        if(parent.containsPress) return "-selected-hover";
                        return "-selected"
                    }

                    anchors.fill: parent

                    border {
                        top: 3
                        bottom: 3
                        right: 3
                        left: 3
                    }
                    source: "qrc:/aero/fileView/item" + state + ".png"

                    visible: parent.containsMouse
                }

                RowLayout {
                    anchors {
                        verticalCenter: parent.verticalCenter

                        left: parent.left
                        right: parent.right

                        leftMargin: 6
                        rightMargin: 6
                    }

                    spacing: 8

                    Kirigami.Icon {
                        implicitWidth: 16
                        implicitHeight: width

                        source: favoritesRoot.model.iconName
                    }

                    Text {
                        Layout.fillWidth: true

                        text: favoritesRoot.model.name
                        color: "#0066cc"
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
