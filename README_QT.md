# Lego App - Qt Version

A cross-platform LEGO set rebuilding application built with Qt and Qt Quick Controls.

## Features

- User authentication with Supabase
- Dashboard with statistics about your LEGO sets
- Browse and organize sets by status (Backlog, Currently Building, Built)
- Cross-platform support (Linux, macOS, Windows)
- Modern, responsive UI with Qt Quick Controls (Material Design style)

## Requirements

- Qt 6.5 or later
- CMake 3.16 or later
- C++17 compatible compiler
- Optional: KDE Frameworks 6 (Kirigami) for enhanced UI

## Building

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed platform-specific instructions.

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
- **main.qml**: Main application window with drawer navigation
- **AuthPage.qml**: Login and registration page
- **DashboardPage.qml**: Dashboard with statistics and currently building sets
- **SetsPage.qml**: Grid view of all sets organized by status
- **SettingsPage.qml**: Settings and account management
- **SetCard.qml**: Reusable component for displaying a LEGO set

## UI Framework

The application uses **Qt Quick Controls 2** with Material Design style by default. If KDE Frameworks 6 (Kirigami) is available during build time, it will be used for enhanced desktop integration on Linux systems.

## Migration from Flutter

This application has been rewritten from Flutter to use Qt/QML. The core functionality remains the same:
- Authentication via Supabase
- CRUD operations for LEGO sets
- Responsive layout that adapts to different screen sizes

See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for more details.

## License

See LICENSE.md

