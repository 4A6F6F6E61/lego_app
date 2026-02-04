# Flutter to Qt/Kirigami Migration Guide

This document outlines the changes made when migrating the Lego App from Flutter to Qt/Kirigami.

## Overview

The application has been completely rewritten from Flutter/Dart to Qt/C++ with QML/Kirigami for the UI. The core functionality remains the same, but the technology stack has changed significantly.

## Technology Stack Comparison

| Aspect | Flutter Version | Qt/Kirigami Version |
|--------|----------------|---------------------|
| Language (Backend) | Dart | C++17 |
| Language (UI) | Dart (Flutter widgets) | QML |
| UI Framework | Flutter Material/Cupertino | Kirigami (KDE) |
| Build System | Flutter build tools | CMake |
| Package Manager | pub | N/A (system packages) |
| State Management | Riverpod | Qt Properties & Signals |
| Routing | go_router | Kirigami PageStack |
| HTTP Client | http package | Qt Network (QNetworkAccessManager) |

## Architecture Changes

### Flutter Architecture

```
lib/
├── main.dart                 # Entry point
├── router.dart              # Navigation config
├── auth_notifier.dart       # Auth state
├── auth_page.dart           # Auth UI
├── navigation_page.dart     # Nav shell
├── tabs/
│   ├── dashboard/
│   ├── sets/
│   └── settings/
├── providers/               # Riverpod providers
├── db/                      # Database models
└── components/             # Reusable widgets
```

### Qt/Kirigami Architecture

```
src/
├── main.cpp                 # Entry point
├── authmanager.h/cpp        # Auth management
├── supabaseclient.h/cpp     # API client
└── legosetmodel.h/cpp       # Data model

qml/
├── main.qml                 # Main window
├── pages/
│   ├── AuthPage.qml         # Login/Register
│   ├── DashboardPage.qml    # Dashboard
│   ├── SetsPage.qml         # Sets list
│   └── SettingsPage.qml     # Settings
└── components/
    └── SetCard.qml          # Set display card
```

## Key Component Mappings

### Authentication

**Flutter:**
- `auth_page.dart` - UI for login/register
- `auth_notifier.dart` - State management
- `supabase_flutter` package - Backend integration

**Qt/Kirigami:**
- `AuthPage.qml` - UI for login/register
- `authmanager.h/.cpp` - State management
- `supabaseclient.h/.cpp` - Backend integration

### Navigation

**Flutter:**
- `go_router` with `StatefulShellRoute`
- `NavigationPage` with adaptive navigation rail/bar

**Qt/Kirigami:**
- `Kirigami.ApplicationWindow` with `GlobalDrawer`
- `pageStack` for page navigation

### Data Models

**Flutter:**
- Dart classes with `fromJson`/`toJson` methods
- Riverpod providers for state management

**Qt/Kirigami:**
- C++ structs/classes
- `QAbstractListModel` for list data
- Qt signals/slots for state changes

### UI Components

**Flutter:**
- Material widgets (Card, ListTile, etc.)
- Custom widgets extending StatelessWidget/StatefulWidget

**Qt/Kirigami:**
- Kirigami components (Card, FormLayout, etc.)
- QML components with properties and signals

## Feature Parity

| Feature | Flutter | Qt/Kirigami | Status |
|---------|---------|-------------|--------|
| User Authentication | ✓ | ✓ | Complete |
| Dashboard View | ✓ | ✓ | Complete |
| Sets List View | ✓ | ✓ | Complete |
| Filter by Status | ✓ | ✓ | Complete |
| Settings Page | ✓ | ✓ | Complete |
| Responsive Layout | ✓ | ✓ | Complete |
| Supabase Integration | ✓ | ✓ | Complete |
| Set Details View | ✓ | ✗ | Not yet implemented |
| Part Tracking | ✓ | ✗ | Not yet implemented |
| Image Caching | ✓ | ✗ | Not yet implemented |

## Benefits of Qt/Kirigami

1. **Native Performance**: C++ backend provides better performance
2. **Desktop Integration**: Better integration with Linux desktop environments, especially KDE
3. **Memory Efficiency**: Generally lower memory footprint than Flutter
4. **Mature Ecosystem**: Qt has been around for decades with extensive documentation
5. **Kirigami**: Modern, adaptive UI framework designed for convergent applications
6. **No JIT/AOT**: Direct native compilation

## Challenges and Considerations

1. **Build Complexity**: CMake setup more complex than Flutter's build system
2. **Dependencies**: Requires Qt and KDE Frameworks to be installed
3. **Cross-platform**: More work needed for consistent look across platforms
4. **Development Speed**: QML + C++ development may be slower than pure Dart
5. **Community Size**: Smaller community compared to Flutter

## Running the Applications

### Flutter Version

```bash
flutter pub get
flutter run
```

### Qt/Kirigami Version

```bash
mkdir build && cd build
cmake ..
cmake --build .
./lego_app
```

## Future Enhancements

Planned improvements for the Qt/Kirigami version:

1. Implement set details page
2. Add part tracking functionality  
3. Implement image caching with Qt Network
4. Add animations and transitions
5. Improve error handling and user feedback
6. Add offline support
7. Implement settings persistence with QSettings
8. Add tests with Qt Test framework

## Conclusion

The migration from Flutter to Qt/Kirigami provides a solid foundation for a native desktop application with excellent KDE integration. While some features are still being ported, the core functionality is complete and working well.
