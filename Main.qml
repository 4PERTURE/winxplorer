import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Window

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

        onShowPathError: {
            errorDialogOverlay.visible = true
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

    Loader {
        id: errorDialogLoader
        
        Connections {
            target: navBar
            function onShowPathError() {
                errorDialogLoader.sourceComponent = errorWindowComponent
            }
        }
    }

    Component {
        id: errorWindowComponent
        
        Window {
            id: errorWindow
            
            title: "Windows Explorer"
            width: 400
            height: 92
            minimumWidth: 400
            maximumWidth: 400
            minimumHeight: 92
            maximumHeight: 92
            flags: Qt.Dialog | Qt.WindowCloseButtonHint
            modality: Qt.ApplicationModal
            color: "#f0f0f0"
            
            onVisibilityChanged: {
                if(visibility === Window.Hidden) {
                    navBar.addressBar.editing = false
                    errorDialogLoader.sourceComponent = undefined
                }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Top content area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#ffffff"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 10
                        
                        // Error icon
                        Image {
                            width: 32
                            height: 32
                            sourceSize.width: 32
                            sourceSize.height: 32
                            source: "qrc:/aero/errorDialogue/error.png"
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        }
                        
                        // Error message
                        Text {
                            id: errorMessage
                            
                            text: "Windows can't find '" + navBar.addressBar.text + "'. Check the spelling and try again."
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 11
                        }
                    }
                }
                
                // Separator line
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#d0d0d0"
                }
                
                // Bottom button area with darker background
                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    color: "#f0f0f0"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.rightMargin: 6
                        anchors.topMargin: 1
                        anchors.bottomMargin: 1
                        anchors.leftMargin: 0
                        spacing: 8
                        
                        Item { Layout.fillWidth: true }
                        
                        QQC2.Button {
                            text: "OK"
                            Layout.preferredWidth: 75
                            onClicked: errorWindow.close()
                        }
                    }
                }
            }
            
            Connections {
                target: errorMessage
                function onImplicitWidthChanged() {
                    let calculatedWidth = errorMessage.implicitWidth + 70;
                    let minW = 340;
                    let maxW = 500;
                    let newWidth = Math.max(minW, Math.min(calculatedWidth, maxW));
                    errorWindow.minimumWidth = newWidth;
                    errorWindow.maximumWidth = newWidth;
                    errorWindow.width = newWidth;
                }
            }
            
            Component.onCompleted: {
                showNormal()
                raise()
                requestActivate()
            }
        }
    }
}
