cmake_minimum_required(VERSION 3.16)

project(lego_app VERSION 0.1.6 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 Network Sql)

# Try to find Kirigami (optional)
find_package(KF6 QUIET COMPONENTS Kirigami CoreAddons I18n)

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
)

# Link Kirigami if available
if(KF6_FOUND)
    target_link_libraries(lego_app PRIVATE
        KF6::Kirigami
        KF6::CoreAddons
        KF6::I18n
    )
    target_compile_definitions(lego_app PRIVATE HAVE_KIRIGAMI)
    message(STATUS "Building with Kirigami support")
else()
    message(STATUS "Building without Kirigami - using Qt Quick Controls only")
endif()

install(TARGETS lego_app
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
