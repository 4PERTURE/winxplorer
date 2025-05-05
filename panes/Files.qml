pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import Controls as Controls

import io.gitgud.catpswin56.private.filesmodel

Item {
    id: paneRoot

    readonly property int count: listView.count

    Controls.FileColumns { id: columns; anchors.top: parent.top }

    MouseArea {
        id: viewArea

        anchors {
            top: columns.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        implicitWidth: columns.rowWidth
        implicitHeight: listView.height

        hoverEnabled: true

        Keys.onPressed: event => {
            switch(event.key) {
                case(Qt.Key_Up):
                    if(listView.currentIndex > 0) listView.currentIndex--;
                    else listView.currentIndex = listView.count-1;
                    break;
                case(Qt.Key_Down):
                    if(listView.currentIndex < listView.count-1) listView.currentIndex++;
                    else listView.currentIndex = 0;
                    break;
                case(Qt.Key_Return):
                    FilesModel.trigger(listView.currentItem.index);
                    break;
                case(Qt.Key_Backspace):
                    FilesModel.goUp();
                    break;
                default:
                    if(event.text !== "") listView.searchStr += event.text;
                    break;
            }
        }

        Text {
            anchors {
                top: parent.top
                topMargin: 16

                horizontalCenter: parent.horizontalCenter
            }

            text: "This folder is empty."

            visible: listView.count === 0
            opacity: 0.5
        }

        // put the listview inside a scrollview to get rid of the
        // flicking and forced smooth scrolling
        QQC2.ScrollView {
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
                            if(FilesModel.data(FilesModel.index(i, 0), 0).slice(0, searchStr.length).toLowerCase() == searchStr) {
                                currentIndex = file.index;
                                positionViewAtIndex(currentIndex, ListView.Contain);
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

                property list<int> selectedIndexes: []

                currentIndex: -1
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                spacing: 1
                highlightMoveVelocity: 0
                highlightMoveDuration: 0
                maximumFlickVelocity: 0
                model: FilesModel
                clip: true
                reuseItems: true
                pressDelay: 0
                boundsBehavior: Flickable.StopAtBounds
                pixelAligned: true
                delegate: MouseArea {
                    id: fileRoot

                    required property var model
                    required property int index

                    width: paneRoot.width - ListView.view.parent.scrollBarWidth
                    height: 19

                    hoverEnabled: true

                    onClicked: {
                        viewArea.forceActiveFocus();
                        listView.currentIndex = model.index;
                    }
                    onDoubleClicked: FilesModel.trigger(index);

                    BorderImage {
                        readonly property string state: {
                            if(listView.currentIndex == parent.index) {
                                if(parent.containsMouse) return "-selected-hover";
                                return "-selected"
                            } else return "-hover";

                            // var basePrefix = listView.currentIndex == index ? "-selected" : ""
                            // if(parent.containsMouse) basePrefix += "-hover";
                            // return basePrefix;
                        }

                        anchors.fill: parent

                        border {
                            top: 3
                            bottom: 3
                            right: 3
                            left: 3
                        }
                        source: "qrc:/aero/fileView/item" + state + ".png"

                        visible: listView.currentIndex == index || parent.containsMouse
                    }

                    RowLayout {
                        anchors {
                            right: parent.right
                            left: parent.left
                            leftMargin: 4

                            verticalCenter: parent.verticalCenter
                        }

                        RowLayout {
                            id: name

                            readonly property int nameColumnWidth: {
                                for(var i = 0; i < columns.columns.count; i++) {
                                    if(columns.columns.get(i).name === "Name")
                                        return columns.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: nameColumnWidth-parent.spacing
                            Layout.maximumWidth: nameColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            spacing: 2

                            Kirigami.Icon {
                                implicitWidth: 16
                                implicitHeight: implicitWidth

                                source: model.iconName

                                opacity: model.isHidden ? 0.5 : 1.0

                                Kirigami.Icon {
                                    anchors.bottom: parent.bottom

                                    width: 8
                                    height: width

                                    source: model.emblemName
                                }
                            }
                            Text {
                                Layout.fillWidth: true

                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                text: model.name
                            }
                        }

                        Text {
                            id: type

                            readonly property int typeColumnWidth: {
                                for(var i = 0; i < columns.columns.count; i++) {
                                    if(columns.columns.get(i).name === "Type")
                                        return columns.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: typeColumnWidth-parent.spacing
                            Layout.maximumWidth: typeColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            text: model.mimeType

                            opacity: 0.5
                        }

                        Text {
                            id: modifiedDate

                            readonly property int dateColumnWidth: {
                                for(var i = 0; i < columns.columns.count; i++) {
                                    if(columns.columns.get(i).name === "Modified date")
                                        return columns.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: dateColumnWidth-parent.spacing
                            Layout.maximumWidth: dateColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            text: model.modifiedDate

                            opacity: 0.5
                        }

                        Text {
                            id: size

                            readonly property int sizeColumnWidth: {
                                for(var i = 0; i < columns.columns.count; i++) {
                                    if(columns.columns.get(i).name === "Size")
                                        return columns.columns.get(i).width;
                                }
                            }

                            Layout.minimumWidth: sizeColumnWidth-parent.spacing
                            Layout.maximumWidth: sizeColumnWidth-parent.spacing
                            Layout.fillHeight: true

                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                            text: model.size

                            opacity: 0.5
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                Connections {
                    target: FilesModel
                    function onCurrentDirChanged() {
                        listView.currentIndex = -1;
                        listView.selectedIndexes = [];
                    }
                }
            }
        }
    }

    Component.onCompleted: viewArea.forceActiveFocus();
}
