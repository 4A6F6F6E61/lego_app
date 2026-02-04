# Building Lego App with Qt/Kirigami

## Prerequisites

Before building the application, you need to install the following dependencies:

### Linux (Ubuntu/Debian)

```bash
# Install Qt 6 and development tools
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    extra-cmake-modules \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-tools-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    libkf6kirigami-dev \
    libkf6coreaddons-dev \
    libkf6i18n-dev
```

### Linux (Fedora)

```bash
sudo dnf install -y \
    cmake \
    extra-cmake-modules \
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel \
    kf6-kirigami-devel \
    kf6-kcoreaddons-devel \
    kf6-ki18n-devel
```

### Linux (Arch)

```bash
sudo pacman -S \
    cmake \
    extra-cmake-modules \
    qt6-base \
    qt6-declarative \
    kirigami \
    kcoreaddons \
    ki18n
```

### macOS

```bash
# Install Homebrew if not already installed
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install cmake qt@6 kde-mac/kde/kf6-kirigami kde-mac/kde/kf6-kcoreaddons kde-mac/kde/kf6-ki18n
```

### Windows

1. Download and install Qt 6 from https://www.qt.io/download
2. Install KDE Craft to get Kirigami and KDE Frameworks: https://community.kde.org/Craft
3. Set up your environment using Craft

## Building

Once you have installed all prerequisites:

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

## Troubleshooting

### Qt not found

If CMake cannot find Qt, you may need to set the Qt6_DIR environment variable:

```bash
export Qt6_DIR=/path/to/qt6/lib/cmake/Qt6
```

### Kirigami not found

If CMake cannot find Kirigami, ensure that KDE Frameworks 6 is installed and set:

```bash
export CMAKE_PREFIX_PATH=/usr/lib/cmake:$CMAKE_PREFIX_PATH
```

### General build issues

For general build issues:

1. Make sure you have all the prerequisites installed
2. Try cleaning the build directory: `rm -rf build && mkdir build`
3. Check CMake output for specific error messages
4. Ensure you're using Qt 6.5 or later and KDE Frameworks 6

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

The application should work on any modern Linux distribution with Qt 6 and KDE Frameworks 6 installed. It integrates well with KDE Plasma but also works on other desktop environments.

### macOS

On macOS, the application will use the native macOS style. Make sure to install all dependencies through Homebrew.

### Windows

On Windows, the application will use the Windows style. The Craft framework makes it easier to manage KDE dependencies on Windows.

## Docker Build (Advanced)

For reproducible builds, you can use Docker:

```bash
# Create a Dockerfile or use this command directly
docker run --rm -v $(pwd):/app -w /app ubuntu:22.04 bash -c "
apt update && \
apt install -y build-essential cmake extra-cmake-modules qt6-base-dev qt6-declarative-dev && \
mkdir -p build && cd build && cmake .. && cmake --build .
"
```

Note: This example is simplified and may require additional setup for KDE Frameworks.
