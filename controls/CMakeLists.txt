qt_add_library(Controls STATIC)

qt_add_qml_module(Controls
    URI "Controls"
    QML_FILES
        CommandButton.qml
        FileColumns.qml
        CommandBar.qml
)
