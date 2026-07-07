# Lego App

A cross-platform LEGO set rebuilding application.

## ⚠️ Major Update: Qt/Kirigami Version

This application has been rewritten to use **Qt and Kirigami** instead of Flutter. The Qt/Kirigami version provides better desktop integration, especially on Linux with KDE, and offers native performance with C++.

### Available Versions

- **Qt/Kirigami Version** (Current - see branch `copilot/rewrite-app-qt-kirigami`): Modern C++/QML application with Kirigami UI
- **Flutter Version** (Original - see main branch): Cross-platform Flutter application

## Features

- User authentication with Supabase
- Dashboard with statistics about your LEGO sets  
- Browse and organize sets by status (Backlog, Currently Building, Built)
- Responsive, adaptive UI
- Cross-platform support (Linux, macOS, Windows)

## Quick Start

### Qt/Kirigami Version

See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed setup instructions.

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt install build-essential cmake qt6-base-dev qt6-declarative-dev libkf6kirigami-dev

# Build
mkdir build && cd build
cmake ..
cmake --build .

# Run
./lego_app
```

### Flutter Version (Original)

```bash
flutter pub get
flutter run
```

## Documentation

- [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) - Detailed build instructions for Qt version
- [README_QT.md](README_QT.md) - Qt/Kirigami version documentation
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Flutter to Qt/Kirigami migration details

## License

See [LICENSE.md](LICENSE.md)
