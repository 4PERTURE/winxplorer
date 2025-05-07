cmake_minimum_required(VERSION 3.16)

project(winxplorer6 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(KF6WindowSystem)
find_package(KF6KIO)
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Quick Multimedia)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(winxplorer
    main.cpp
)

qt_add_qml_module(winxplorer
    URI appwinxplorer
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES aero.qrc
        SOURCES filesmodel.h filesmodel.cpp
    DEPENDENCIES
        Controls
        Panes
)

add_subdirectory(controls/)
add_subdirectory(panes/)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should con sider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(winxplorer PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.winxplorer
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(winxplorer
    PRIVATE
        Qt6::Quick
        Qt6::Core
        Qt6::Widgets
        Qt6::Multimedia

        Controlsplugin Panesplugin
    PUBLIC
        KF6::WindowSystem
        KF6::KIOCore
)

include(GNUInstallDirs)
install(TARGETS winxplorer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
