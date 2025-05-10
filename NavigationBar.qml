import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

RowLayout {
    id: navBar

    property alias addressBar: addressBar

    implicitHeight: 36

    spacing: 0

    component AeroBar: MouseArea {
        id: bar

        property bool search: false
        property alias text: txt.text
        property string icon: ""

        hoverEnabled: true

        implicitHeight: 24

        BorderImage {
            readonly property string state: {
                if(parent.enabled) {
                    if(parent.containsMouse) return "hover";
                    return "normal";
                }
                return "disabled";
            }

            anchors.fill: parent

            border {
                top: 3
                bottom: 3
                left: 3
                right: 3
            }
            source: "qrc:/aero/glassArea/addressBar/" + state + ".png"
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
            target: filesModel
            function onRefresh() {
                navigationBtns.history = Qt.binding(() => filesModel.history(2));
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

            // TODO: move this to FilesBackend
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
                                    filesModel.currentDir = navigationBtns.history[index];
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
            anchors.topMargin: 1
            anchors.rightMargin: 13

            spacing: -1

            MouseArea {
                width: 29
                height: 27

                hoverEnabled: true

                onClicked: {
                    filesModel.goBack()
                    bckImg.canGoBack = Qt.binding(() => filesModel.canGoBack)
                    fwdImg.canGoForward = Qt.binding(() => filesModel.canGoForward)
                }

                Image {
                    id: bckImg

                    property bool canGoBack: false

                    Binding {
                        target: bckImg
                        property: "canGoBack"
                        value: filesModel.canGoBack
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
                    filesModel.goForward()
                    bckImg.canGoBack = Qt.binding(() => filesModel.canGoBack)
                    fwdImg.canGoForward = Qt.binding(() => filesModel.canGoForward)
                }

                Image {
                    id: fwdImg

                    property bool canGoForward: false

                    Binding {
                        target: fwdImg
                        property: "canGoForward"
                        value: filesModel.canGoForward
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

        icon: filesModel.currentDirIcon
        text: filesModel.currentDir

        Row {
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right

                margins: 1
            }

            component CrumbBtn: MouseArea {
                property bool flat: false

                hoverEnabled: true

                BorderImage {
                    readonly property string state: {
                        if(parent.enabled) {
                            if(parent.containsPress) return "pressed";
                            if(parent.containsMouse) return "hover";
                            return "normal";
                        }
                        return "disabled";
                    }

                    anchors.fill: parent

                    border {
                        top: 3
                        bottom: 2
                        left: 3
                        right: 2
                    }
                    source: "qrc:/aero/misc/squareBtns/" + state + ".png"

                    opacity: parent.flat ? parent.containsMouse : true

                    Behavior on opacity {
                        NumberAnimation { duration: 125 }
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 1

                width: 1

                color: "black"
                opacity: 0.5
            }

            CrumbBtn {
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: height+4

                flat: true
                onClicked: filesModel.refresh()

                Kirigami.Icon {
                    anchors.centerIn: parent

                    width: 16
                    height: 16

                    source: "gtk-refresh"
                }
            }
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
