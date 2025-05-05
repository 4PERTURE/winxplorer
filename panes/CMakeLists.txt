qt_add_library(Panes STATIC)

qt_add_qml_module(Panes
    URI "Panes"
    QML_FILES
        Files.qml
        Navigation.qml
        Preview.qml
        Details.qml
)
