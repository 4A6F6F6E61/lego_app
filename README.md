# Lego Tracker

A cross-platform LEGO set rebuilding and inventory tracking application. Built with Flutter, Supabase, and Material 3 Expressive.

## 🚀 Features

- **Set Tracking & Organization:** View your entire Lego set collection, filter by build status, and track your rebuilding progress.
- **Advanced Part Inventory:** 
  - Manage individual parts needed for a set.
  - Mark parts as found, missing, or spare.
  - "Unable to find" parts highlight in red, and "Spare" parts in purple for quick visual identification.
- **Rebrickable Integration:** Securely sync your collection, fetch accurate part metadata, and load official Lego colors.
- **Brickset Integration:** Automatically fetch and open official PDF building instructions for your sets.
- **Cross-Platform & Desktop Native:** Optimized for all screen sizes with responsive dashboards, navigation rails, and a seamless native desktop experience (using `window_manager` for window management and `url_launcher` for URL launching).
- **Cloud Sync:** Real-time database and user authentication powered by Supabase.

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (Linux, macOS, Windows, Android, iOS, Web)
- **State Management:** [Riverpod](https://riverpod.dev/) (`hooks_riverpod` + `riverpod_annotation`)
- **Backend:** [Supabase](https://supabase.com) (PostgreSQL Database & Auth)
- **UI / Design System:** 
  - `material_3_expressive` and `material_ui` for modern, expressive Material components.
  - `motor` for smooth layout animations.
- **Native OS Integrations:** `window_manager` configures desktop window sizes and positioning, while `url_launcher` securely opens external URLs across supported platforms.

## 📁 Core Code Architecture

For future developers and AI agents, here is a high-level overview of how the app is structured:

### Database & Models (`lib/db/models/`)
- `LegoSet`: Represents a tracked set, linking to Rebrickable's set number, theme, and overall build status.
- `SetPart`: Represents an individual piece in a set. Tracks `quantityNeeded`, `quantityFound`, `isSpare`, and `isLost`.

### API Integrations (`lib/api/`)
- **Rebrickable API**: Separated into services (`lego_api.dart`, `users_api.dart`). Fetches parts lists, colors, and user collections.
- **Brickset API**: `brickset_api.dart` handles fetching external resources like PDF instruction manuals.

### State & Providers (`lib/providers/`)
- `settings.dart`: Manages local application state like the Rebrickable API Key, Brickset API Key, and User Tokens (persisted locally).
- `db_providers.dart`: Handles Supabase queries, marking parts as lost/spare, updating set statuses, and incrementing found quantities.
- `rebrickable_providers.dart`: Handles caching complex API data (like the global color palette).

### UI Tabs (`lib/tabs/`)
- **Dashboard**: High-level overview, quick actions, and recent sets. Responsive layout adapts from mobile to wide desktop screens.
- **Sets**: The core list of tracked sets. Features the `DetailsPage` where individual parts are tracked.
  - `PartDetailDialog`: The modal where users can increment parts or toggle the "Unable to find" / "Spare" flags.
- **Settings**: Authentication logic, API key configuration, and theme toggles.

## 💻 Running the App

1. Ensure you have the Flutter SDK (via [FVM](https://fvm.app/) recommended, checking `pubspec.yaml` for exact version constraint).
2. Configure Supabase environment variables if building from scratch (the app currently initializes with a public key in `main.dart`).
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run -d <platform>` to start the app.
