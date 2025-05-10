pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import Controls as Controls

Item {
    id: paneRoot

    readonly property int count: listView.count

    MouseArea {
        id: viewArea

        anchors.fill: parent

        hoverEnabled: true

        Keys.onPressed: event => {
            switch(event.key) {
                case(Qt.Key_Up):
                    if(listView.selectedIndex > 0) listView.selectedIndex--;
                    else listView.selectedIndex = listView.count-1;
                    break;
                case(Qt.Key_Down):
                    if(listView.selectedIndex < listView.count-1) listView.selectedIndex++;
                    else listView.selectedIndex = 0;
                    break;
                case(Qt.Key_Return):
                    filesModel.trigger(listView.currentItem.index);
                    break;
                case(Qt.Key_Backspace):
                    filesModel.goUp();
                    break;
                default:
                    if(event.text !== "") listView.searchStr += event.text;
                    break;
            }
        }

        Row {
            id: separatorLines

            anchors.fill: parent

            Repeater {
                model: listView.headerItem.count
                delegate: Item {
                    required property int index

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: listView.headerItem.columns.get(index).width

                    Row {
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                        }

                        Rectangle {
                            width: 1
                            height: parent.height

                            color: "#ededed"
                        }
                        Rectangle {
                            width: 1
                            height: parent.height

                            color: "white"
                        }
                    }
                }
            }
        }

        Text {
            anchors {
                top: parent.top
                topMargin: 16 + listView.headerItem.height

                horizontalCenter: parent.horizontalCenter
            }

            text: "This folder is empty."

            visible: listView.count === 0
            opacity: 0.5
        }

        // put the listview inside a scrollview to get rid of the
        // flicking and forced smooth scrolling
        BorderImage {
            anchors {
                right: listScrollView.right
                left: listScrollView.left
            }

            height: 24

            border {
                top: 0
                bottom: 2
                right: 0
                left: 2
            }
            source: "qrc:/aero/fileView/header/background.png"
        }

        QQC2.ScrollView {
            id: listScrollView

            anchors.fill: parent

            readonly property real scrollBarWidth: QQC2.ScrollBar.vertical.visible ? QQC2.ScrollBar.vertical.width : 0

            ListView {
                id: listView

                property string searchStr: ""
                onSearchStrChanged: {
                    resetSearchStr.restart();
                    if(searchStr !== "") {
                        for(var i = 0; i < count; i++) {
                            var file = listView.itemAtIndex(i);
                            if(filesModel.data(filesModel.index(i, 0), 0).slice(0, searchStr.length).toLowerCase() == searchStr) {
                                selectedIndex = file.index;
                                positionViewAtIndex(selectedIndex, ListView.Contain);
                                return;
                            }
                        }
                    }
                }
                Timer {
                    id: resetSearchStr

                    interval: 1000
                    onTriggered: listView.searchStr = "";
                }

                property int selectedIndex: -1
                Binding {
                    target: listView
                    property: "currentIndex"
                    value: listView.selectedIndex
                    restoreMode: Binding.RestoreValue
                }

                //property list<int> selectedIndexes: []

                contentWidth: headerItem.columnsWidth

                Connections {
                    target: filesModel

                    function onCurrentDirChanged() {
                        listView.selectedIndex = -1;
                    }
                }

                currentIndex: selectedIndex
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                onCountChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                spacing: 1
                highlightMoveVelocity: 0
                highlightMoveDuration: 0
                maximumFlickVelocity: 0
                model: filesModel
                clip: true
                reuseItems: true
                header: Controls.FileColumns { id: columns }
                headerPositioning: ListView.OverlayHeader
                pressDelay: 0
                boundsBehavior: Flickable.StopAtBounds
                pixelAligned: true
                delegate: MouseArea {
                    id: fileRoot

                    required property var model
                    required property int index

                    width: listView.headerItem.columnsWidth
                    height: 19

                    hoverEnabled: true

                    onClicked: {
                        viewArea.forceActiveFocus();
                        listView.selectedIndex = model.index;
                    }
                    onDoubleClicked: {
                        viewArea.forceActiveFocus();
                        listView.selectedIndex = model.index;
                        filesModel.trigger(index);
                    }

                    BorderImage {
                        readonly property string state: {
                            if(listView.selectedIndex == parent.index) {
                                if(parent.containsMouse) return "-selected-hover";
                                return "-selected"
                            } else return "-hover";
                        }

                        anchors.fill: parent

                        border {
                            top: 3
                            bottom: 3
                            right: 3
                            left: 3
                        }
                        source: "qrc:/aero/fileView/item" + state + ".png"

                        visible: listView.selectedIndex == fileRoot.index || parent.containsMouse
                    }

                    RowLayout {
                        anchors {
                            right: parent.right
                            left: parent.left
                            leftMargin: 4

                            verticalCenter: parent.verticalCenter
                        }

                        spacing: 10

                        RowLayout {
                            id: name

                            readonly property int nameColumnWidth: {
                                for(var i = 0; i < listView.headerItem.columns.count; i++) {
                                    if(listView.headerItem.columns.get(i).name === "Name")
                                        return listView.headerItem.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: nameColumnWidth-parent.spacing
                            Layout.maximumWidth: nameColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            spacing: 2

                            Kirigami.Icon {
                                implicitWidth: 16
                                implicitHeight: implicitWidth

                                source: fileRoot.model.iconName

                                opacity: fileRoot.model.isHidden ? 0.5 : 1.0

                                Kirigami.Icon {
                                    anchors.bottom: parent.bottom

                                    width: 8
                                    height: width

                                    source: fileRoot.model.emblemName
                                }
                            }
                            Text {
                                Layout.fillWidth: true

                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                text: fileRoot.model.name
                            }
                        }

                        Text {
                            id: type

                            readonly property int typeColumnWidth: {
                                for(var i = 0; i < listView.headerItem.columns.count; i++) {
                                    if(listView.headerItem.columns.get(i).name === "Type")
                                        return listView.headerItem.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: typeColumnWidth-parent.spacing
                            Layout.maximumWidth: typeColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            text: fileRoot.model.mimeType
                        }

                        Text {
                            id: modifiedDate

                            readonly property int dateColumnWidth: {
                                for(var i = 0; i < listView.headerItem.columns.count; i++) {
                                    if(listView.headerItem.columns.get(i).name === "Date modified")
                                        return listView.headerItem.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: dateColumnWidth-parent.spacing
                            Layout.maximumWidth: dateColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            text: fileRoot.model.modifiedDate
                        }

                        Text {
                            id: size

                            readonly property int sizeColumnWidth: {
                                for(var i = 0; i < listView.headerItem.columns.count; i++) {
                                    if(listView.headerItem.columns.get(i).name === "Size")
                                        return listView.headerItem.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: sizeColumnWidth-parent.spacing
                            Layout.maximumWidth: sizeColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            text: fileRoot.model.size
                            horizontalAlignment: Text.AlignRight
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
    }

    Component.onCompleted: viewArea.forceActiveFocus();
}
