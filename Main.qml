import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore

import Controls as Controls
import Panes as Panes

import io.gitgud.catpswin56.private.filesbackend as FilesBackend

Window {
    id: root

    property Item selectedFile: null

    width: 786
    height: 534

    title: qsTr("Windows Explorer")
    color: "transparent"

    visible: true

    Component.onCompleted: filesModel.currentDir = "/";

    NavigationBar {
        id: navBar

        anchors {
            right: parent.right
            left: parent.left

            leftMargin: 2
        }

        Component.onCompleted: {
            navBar.addressBar.path = Qt.binding(() => filesModel.currentDir);
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

    FilesBackend.FilesModel {
        id: filesModel
    }
    FilesBackend.FavoritesModel {
        id: favoritesModel

        filesModel: filesModel
    }

    ColumnLayout {
        id: innerContents

        property alias filesPane: filesPane

        anchors.fill: innerRect
        anchors.margins: 2

        spacing: 0

        Connections {
            target: navBar
            function onSearchTextChanged() {
                filesPane.searchFilter = navBar.searchText;
            }
        }

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

            Panes.Navigation { Layout.minimumWidth: 160; Layout.maximumWidth: 160; Layout.fillHeight: true }
            PaneSeparator { Layout.fillHeight: true }
            Panes.Files { id: filesPane; Layout.fillWidth: true; Layout.fillHeight: true }
        }
        Rectangle { Layout.fillWidth: true; Layout.minimumHeight: 1; color: "#9db6c5" }
        Panes.Details { id: detailsPane; Layout.fillWidth: true }
    }
}
