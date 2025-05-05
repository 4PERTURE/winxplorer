pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: columnsRoot

    readonly property alias columns: columns
    readonly property alias columnsWidth: columnsRow.width

    implicitWidth: parent.width
    implicitHeight: 24

    ListModel {
        id: columns

        ListElement {
            name: "Name"
            width: 165
        }
        ListElement {
            name: "Type"
            width: 110
        }
        ListElement {
            name: "Modified date"
            width: 180
        }
        ListElement {
            name: "Size"
            width: 130
        }
    }

    BorderImage {
        anchors.fill: parent

        border {
            top: 0
            bottom: 2
            right: 0
            left: 2
        }
        source: "qrc:/aero/fileView/header/background.png"
    }

    Row {
        id: columnsRow

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        spacing: 0

        Repeater {
            model: columns
            delegate: Item {
                required property int index
                required property var model

                width: model.width
                height: parent.height

                BorderImage {
                    anchors.fill: parent

                    border {
                        top: 0
                        bottom: 2
                        left: 2
                        right: 2
                    }
                    source: "qrc:/aero/fileView/header/item-normal.png"
                }

                Text {
                    anchors.fill: parent

                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 6
                    text: model.name
                }
            }
        }
    }
}
