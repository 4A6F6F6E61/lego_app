cmake_minimum_required(VERSION 3.16)

project(lego_app VERSION 0.1.6 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 Network Sql)
find_package(KF6 REQUIRED COMPONENTS Kirigami CoreAddons I18n)

add_executable(lego_app
    src/main.cpp
    src/authmanager.cpp
    src/authmanager.h
    src/legosetmodel.cpp
    src/legosetmodel.h
    src/supabaseclient.cpp
    src/supabaseclient.h
    qml/qml.qrc
)

target_link_libraries(lego_app PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Sql
    KF6::Kirigami
    KF6::CoreAddons
    KF6::I18n
)

install(TARGETS lego_app
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
