import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    id: detailsPane

    readonly property string iconName: root.selectedFile != null ? root.selectedFile.model.iconName : filesModel.currentDirIcon
    readonly property string header: root.selectedFile != null ? root.selectedFile.model.name : filesModel.count + " items"
    readonly property string description: root.selectedFile != null ? root.selectedFile.model.mimeType : ""

    readonly property bool isFile: root.selectedFile != null
    readonly property string dateModified: root.selectedFile != null ? root.selectedFile.model.modifiedDate : ""
    readonly property string size: root.selectedFile != null ? root.selectedFile.model.size : ""
    readonly property string dateCreated: root.selectedFile != null ? root.selectedFile.model.createdDate : ""

    implicitHeight: 70

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.5; color: "#f3fbfe" }
            GradientStop { position: 1.0; color: "#bbd9f0" }
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
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: 4
            right: parent.right
            rightMargin: 4
        }

        spacing: 4

        Kirigami.Icon {
            id: icon

            width: 64
            height: width

            source: detailsPane.iconName
        }

        Item { width: 7; height: 1 }

        ColumnLayout {
            anchors.top: parent.top

            uniformCellSizes: true
            spacing: 2

            Text {
                text: detailsPane.header
                font.pointSize: 10
            }
            Text {
                text: detailsPane.description
            }
            Item { Layout.fillHeight: true }
        }
        RowLayout {
            anchors.top: parent.top

            spacing: 2

            visible: detailsPane.isFile

            ColumnLayout {
                spacing: 0

                Text {
                    Layout.minimumWidth: parent.width

                    text: "Date modified: "
                    horizontalAlignment: Text.AlignRight
                    opacity: 0.5
                }
                Text {
                    Layout.minimumWidth: parent.width

                    text: "Size: "
                    horizontalAlignment: Text.AlignRight
                    opacity: 0.5
                }
                Text {
                    Layout.minimumWidth: parent.width

                    text: "Date created: "
                    horizontalAlignment: Text.AlignRight
                    opacity: 0.5
                }
            }
            ColumnLayout {
                uniformCellSizes: true
                spacing: 0

                Text { text: detailsPane.dateModified }
                Text { text: detailsPane.size }
                Text { text: detailsPane.dateCreated }
            }
        }
    }
}
