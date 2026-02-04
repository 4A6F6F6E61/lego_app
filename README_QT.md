# Lego App - Qt/Kirigami Version

A cross-platform LEGO set rebuilding application built with Qt and Kirigami.

## Features

- User authentication with Supabase
- Dashboard with statistics about your LEGO sets
- Browse and organize sets by status (Backlog, Currently Building, Built)
- Cross-platform support (Linux, macOS, Windows)
- Modern, responsive UI with Kirigami

## Requirements

- Qt 6.5 or later
- KDE Frameworks 6 (Kirigami)
- CMake 3.16 or later
- C++17 compatible compiler

## Building

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

## Running

```bash
./lego_app
```

## Architecture

The application is structured as follows:

### C++ Backend
- **SupabaseClient**: Handles all communication with the Supabase backend
- **AuthManager**: Manages user authentication state
- **LegoSetModel**: QAbstractListModel for displaying LEGO sets

### QML Frontend
- **main.qml**: Main application window with Kirigami navigation
- **AuthPage.qml**: Login and registration page
- **DashboardPage.qml**: Dashboard with statistics and currently building sets
- **SetsPage.qml**: Grid view of all sets organized by status
- **SettingsPage.qml**: Settings and account management
- **SetCard.qml**: Reusable component for displaying a LEGO set

## Migration from Flutter

This application has been rewritten from Flutter to use Qt/Kirigami. The core functionality remains the same:
- Authentication via Supabase
- CRUD operations for LEGO sets
- Responsive layout that adapts to different screen sizes

## License

See LICENSE.md
