import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import Controls as Controls
import Panes as Panes

import io.gitgud.catpswin56.private.filesmodel

Window {
    width: 786
    height: 534
    visible: true
    title: qsTr("Windows Explorer")
    color: "transparent"

    Connections {
        target: FilesModel
        function onRefresh() {
            addressBar.text.text = FilesModel.currentDir;
            addressBar.icon = Qt.binding(() => FilesModel.currentDirIcon);
            updateDetailsIcon.start();
            updateAddressBarIcon.start();
        }
    }

    Component.onCompleted: {
        FilesModel.currentDir = "/";
    }

    component AeroBar: Item {
        id: bar

        property bool search: false
        property alias text: txt
        property string icon: ""

        implicitHeight: 24

        BorderImage {
            anchors.fill: parent

            border {
                top: 3
                bottom: 3
                left: 3
                right: 3
            }
            source: "qrc:/aero/glassArea/addressBar/normal.png"
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 4

            spacing: 4

            layoutDirection: search ? Qt.RightToLeft : Qt.LeftToRight

            Kirigami.Icon {
                implicitWidth: 16
                implicitHeight: width

                source: search ? "gtk-search" : addressBar.icon
            }

            Text {
                id: txt

                Layout.fillWidth: true

                text: search ? "Search..." : addressBar.path
                font.italic: search
                leftPadding: bar.search ? 4 : 0

                opacity: search ? 0.8 : 1.0
            }
        }
    }

    RowLayout {
        id: navBar

        anchors {
            right: parent.right
            left: parent.left

            leftMargin: 2
        }

        height: 36

        spacing: 0

        Image {
            readonly property string state: "disabled"

            source: "qrc:/aero/glassArea/navButtons/" + state + ".png"

            MouseArea {
                id: historyMa

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: 13
                height: 23

                hoverEnabled: true
            }

            Row {
                anchors.fill: parent
                anchors.rightMargin: 13

                spacing: -1

                MouseArea {
                    width: 29
                    height: 27

                    hoverEnabled: true

                    onClicked: {
                        FilesModel.goBack()
                        bckImg.canGoBack = Qt.binding(() => FilesModel.canGoBack)
                        fwdImg.canGoForward = Qt.binding(() => FilesModel.canGoForward)
                    }

                    Image {
                        id: bckImg

                        property bool canGoBack: false

                        Binding {
                            target: bckImg
                            property: "canGoBack"
                            value: FilesModel.canGoBack
                            restoreMode: Binding.RestoreValue
                        }

                        readonly property string state: {
                            if(parent.containsPress) return "pressed";
                            if(parent.containsMouse) return "hover";
                            return "normal";
                        }

                        anchors.fill: parent

                        source: "qrc:/aero/glassArea/navButtons/back/" + (canGoBack ? state : "disabled") + ".png"
                    }
                }

                MouseArea {
                    width: 29
                    height: 27

                    hoverEnabled: true

                    onClicked: {
                        FilesModel.goForward()
                        bckImg.canGoBack = Qt.binding(() => FilesModel.canGoBack)
                        fwdImg.canGoForward = Qt.binding(() => FilesModel.canGoForward)
                    }

                    Image {
                        id: fwdImg

                        property bool canGoForward: false

                        Binding {
                            target: fwdImg
                            property: "canGoForward"
                            value: FilesModel.canGoForward
                            restoreMode: Binding.RestoreValue
                        }

                        readonly property string state: {
                            if(parent.containsPress) return "pressed";
                            if(parent.containsMouse) return "hover";
                            return "normal";
                        }

                        anchors.fill: parent

                        source: "qrc:/aero/glassArea/navButtons/forward/" + (canGoForward ? state : "disabled") + ".png"
                    }
                }
            }
        }

        AeroBar {
            id: addressBar

            Layout.fillWidth: true

            // delay the icon update otherwise it'll use the last visited directory icon
            Timer {
                id: updateAddressBarIcon

                interval: 50
                onTriggered: addressBar.icon = FilesModel.currentDirIcon
            }
        }

        Item { Layout.preferredWidth: 4 }

        AeroBar {
            id: searchBar

            Layout.minimumWidth: 240
            Layout.maximumWidth: 240

            search: true
        }
    }

    Rectangle {
        id: innerRect

        anchors {
            top: navBar.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        color: "black"
        border.width: 1
        border.color: "white"
        radius: 2

        opacity: 0.5
    }

    Rectangle { anchors.fill: innerContents; color: "#fcfcfc" }

    ColumnLayout {
        id: innerContents

        anchors.fill: innerRect
        anchors.margins: 2

        spacing: 0

        Controls.CommandBar { id: commandBar; Layout.fillWidth: true }

        RowLayout {
            id: panes

            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 0

            Item {
                Layout.minimumWidth: 160
                Layout.maximumWidth: 160
                Layout.fillHeight: true

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: 2

                    color: "#a7bac5"
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: 1

                    color: "white"
                }

                Text {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 12
                    anchors.leftMargin: 11
                    text: "Favorite Links"
                    opacity: 0.5
                }
            }

            Panes.Files { id: filesPane; Layout.fillWidth: true; Layout.fillHeight: true }
        }
        Rectangle { Layout.fillWidth: true; Layout.minimumHeight: 1; color: "#9db6c5" }
        Item {
            id: detailsPane

            Layout.fillWidth: true
            Layout.minimumHeight: 70
            Layout.maximumHeight: 70

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

                    text: filesPane.count + " elements"
                    font.pointSize: 10
                }
            }
        }
    }
}
