import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore

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
            detailsPane.updateDetailsIcon.start();
            updateAddressBarIcon.start();
        }
    }

    Component.onCompleted: FilesModel.currentDir = "/";

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
            id: navigationBtns

            property list<string> history: []
            readonly property string state: {
                if(history.length > 0) {
                    if(historyMa.containsPress || listMenu.opened) return "pressed";
                    if(historyMa.containsMouse) return "hover";
                    return "normal"
                } else return "disabled";
            }

            Connections {
                target: FilesModel
                function onRefresh() {
                    navigationBtns.history = Qt.binding(() => FilesModel.history(2));
                }
            }

            source: "qrc:/aero/glassArea/navButtons/" + state + ".png"

            MouseArea {
                id: historyMa

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                width: 13
                height: 23

                hoverEnabled: true
                onClicked: listMenu.open()

                QQC2.Menu {
                    id: listMenu

                    width: 234
                    height: listMenuView.contentHeight + 12

                    y: historyMa.height

                    contentItem: ListView {
                        id: listMenuView

                        anchors {
                            fill: parent
                            topMargin: 2
                            bottomMargin: 12
                            leftMargin: 2
                            rightMargin: 10
                        }

                        spacing: 2
                        model: navigationBtns.history.length
                        delegate: Item {
                            id: itemRoot

                            required property int index

                            width: parent.width
                            height: 19

                            Item {
                                id: normalItem

                                anchors.fill: parent

                                BorderImage {
                                    anchors.fill: parent

                                    border {
                                        top: 2
                                        bottom: 3
                                        right: 3
                                        left: 3
                                    }
                                    source: "qrc:/aero/fileView/item-hover.png"

                                    visible: itemMa.containsMouse
                                }

                                Text {
                                    anchors {
                                        right: parent.right
                                        left: parent.left
                                        leftMargin: 28

                                        verticalCenter: parent.verticalCenter
                                    }

                                    text: navigationBtns.history[index]
                                    verticalAlignment: Text.AlignVCenter
                                }

                                MouseArea {
                                    id: itemMa

                                    anchors.fill: parent

                                    hoverEnabled: true
                                    preventStealing: true
                                    propagateComposedEvents: true
                                    onClicked: {
                                        listMenu.close();
                                        FilesModel.currentDir = navigationBtns.history[index];
                                    }

                                    z: 1
                                }
                            }
                        }

                        Rectangle {
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                bottomMargin: -2
                                left: parent.left
                                leftMargin: 22
                            }

                            width: 1

                            color: "#e2e2e2"

                            z: -1
                        }
                        Rectangle {
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                bottomMargin: -2
                                left: parent.left
                                leftMargin: 23
                            }

                            width: 1

                            color: "#fefefe"

                            z: -1
                        }
                    }

                    background: Kirigami.ShadowedRectangle {
                        anchors {
                            fill: parent
                            rightMargin: 8
                            bottomMargin: 8
                        }
                        radius: 0
                        color: "white"

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2

                            color: "#efefef"
                        }

                        border.color: "#a6a6a6"
                        border.width: 1

                        shadow.xOffset: 1
                        shadow.yOffset: 1
                        shadow.color: Qt.rgba(0, 0, 0, 0.3)
                        shadow.size: 4
                    }
                }
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

        property alias filesPane: filesPane

        anchors.fill: innerRect
        anchors.margins: 2

        spacing: 0

        component PaneSeparator: Item {
            implicitWidth: 2

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
        }

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

                Text {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 12
                    anchors.leftMargin: 11
                    text: "Favorite Links"
                    opacity: 0.5
                }
            }
            PaneSeparator { Layout.fillHeight: true }
            Panes.Files { id: filesPane; Layout.fillWidth: true; Layout.fillHeight: true }
        }
        Rectangle { Layout.fillWidth: true; Layout.minimumHeight: 1; color: "#9db6c5" }
        Panes.Details { id: detailsPane; Layout.fillWidth: true }
    }
}
