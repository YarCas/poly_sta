cmake_minimum_required(VERSION 3.16)

project(PLM VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(Qt6 REQUIRED COMPONENTS Quick
    Location        # Для работы с картами
    Positioning     # Для геокоординат
    QuickControls2  # Для UI элементов)
)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appPLM
    main.cpp
)

qt_add_qml_module(appPLM
    URI PLM
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES
        QML_FILES PolyView.qml
        QML_FILES EditablePolygon.qml
        SOURCES polygonmanager.h polygonmanager.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appPLM PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appPLM
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appPLM
    PRIVATE  Qt6::Quick
    Qt6::Location         # Для Map, MapPolygon
    Qt6::Positioning      # Для QGeoCoordinate
    Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appPLM
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
