pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: columnsRoot

    readonly property alias columns: columns
    readonly property alias columnsWidth: columnsRow.width
    readonly property alias count: columns.count

    implicitWidth: parent.width
    implicitHeight: 24

    z: 999999

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
            name: "Date modified"
            width: 180
        }
        ListElement {
            name: "Size"
            width: 130
        }
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
                id: columnRoot

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
                    source: parent.index == 0 ? "qrc:/aero/fileView/header/item-normal-first.png" : "qrc:/aero/fileView/header/item-normal.png"
                }

                Text {
                    anchors.fill: parent

                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 6
                    text: columnRoot.model.name
                }
            }
        }
    }
}
