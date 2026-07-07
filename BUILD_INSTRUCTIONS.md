# Building Lego App with Qt

## Prerequisites

Before building the application, you need to install Qt 6. Kirigami is **optional** - the app will build with Qt Quick Controls if Kirigami is not available.

### Linux (Ubuntu/Debian)

```bash
# Install Qt 6 and development tools
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    qt6-base-dev \
    qt6-declarative-dev \
    libgl1-mesa-dev

# Optional: Install Kirigami for enhanced UI
sudo apt install -y \
    extra-cmake-modules \
    libkf6kirigami-dev \
    libkf6coreaddons-dev \
    libkf6i18n-dev
```

### Linux (Fedora)

```bash
sudo dnf install -y \
    cmake \
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel

# Optional: Install Kirigami for enhanced UI
sudo dnf install -y \
    extra-cmake-modules \
    kf6-kirigami-devel \
    kf6-kcoreaddons-devel \
    kf6-ki18n-devel
```

### Linux (Arch)

```bash
sudo pacman -S \
    cmake \
    qt6-base \
    qt6-declarative

# Optional: Install Kirigami for enhanced UI
sudo pacman -S \
    extra-cmake-modules \
    kirigami \
    kcoreaddons \
    ki18n
```

### macOS

```bash
# Install Homebrew if not already installed
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install cmake qt@6

# Optional: Install Kirigami for enhanced UI (via Craft)
# See https://community.kde.org/Craft for Kirigami installation
```

### Windows

1. Download and install Qt 6 from https://www.qt.io/download
2. Ensure CMake is installed (included with Qt installer or download separately)
3. Optional: Install KDE Craft for Kirigami support: https://community.kde.org/Craft

## Building

Once you have installed Qt 6:

```bash
# Create build directory
mkdir build
cd build

# Configure the project
cmake ..

# Build
cmake --build .

# Run the application
./lego_app
```

## UI Framework Notes

The application uses **Qt Quick Controls 2** by default, which provides a Material Design-inspired interface. If KDE Frameworks 6 (Kirigami) is detected during the build, it will be used for an enhanced UI experience optimized for desktop environments.

### Building with Qt Quick Controls Only

The application will automatically detect if Kirigami is available. If not found, it will build using Qt Quick Controls 2:

```
-- Building without Kirigami - using Qt Quick Controls only
```

### Building with Kirigami (Optional)

If Kirigami is installed, CMake will detect it and enable enhanced features:

```
-- Building with Kirigami support
```

## Troubleshooting

### Qt not found

If CMake cannot find Qt, you may need to set the Qt6_DIR environment variable:

```bash
export Qt6_DIR=/path/to/qt6/lib/cmake/Qt6
```

### OpenGL/Graphics issues on Linux

If you encounter OpenGL-related errors:

```bash
sudo apt install libgl1-mesa-dev libqt6opengl6-dev
```

### General build issues

For general build issues:

1. Make sure you have Qt 6.5 or later installed
2. Try cleaning the build directory: `rm -rf build && mkdir build`
3. Check CMake output for specific error messages
4. Verify your compiler supports C++17

## Development

### IDE Setup

#### Qt Creator

Qt Creator is the recommended IDE for Qt development:

1. Open Qt Creator
2. Open the `CMakeLists.txt` file
3. Configure the project with your Qt 6 kit
4. Build and run

#### Visual Studio Code

For VS Code:

1. Install the CMake Tools extension
2. Open the project folder
3. Configure CMake with Qt 6
4. Build using the CMake Tools interface

### Running with Debug Output

To see debug output and QML warnings:

```bash
QT_LOGGING_RULES="*.debug=true" ./lego_app
```

## Cross-Platform Notes

### Linux

The application works on any modern Linux distribution with Qt 6 installed. The Material style is used by default, with optional Kirigami support for KDE Plasma integration.

### macOS

On macOS, the application uses the native macOS style through Qt. Make sure to install Qt 6 through Homebrew.

### Windows

On Windows, the application uses the Windows style. Install Qt 6 through the official Qt installer.

## Docker Build (Advanced)

For reproducible builds using Qt Quick Controls only:

```bash
docker run --rm -v $(pwd):/app -w /app ubuntu:22.04 bash -c "
apt update && \
apt install -y build-essential cmake qt6-base-dev qt6-declarative-dev libgl1-mesa-dev && \
mkdir -p build && cd build && cmake .. && cmake --build .
"
```

## CI/CD Builds

The GitHub Actions workflow builds the application on Linux, macOS, and Windows using Qt Quick Controls only (no Kirigami dependency). This ensures the application can be built in CI environments where KDE Frameworks may not be readily available.

