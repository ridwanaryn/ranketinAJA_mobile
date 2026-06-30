# raketinAJA

A Flutter-based sports court booking application for discovering and reserving sports venues such as badminton and padel courts. The app supports two roles:

- **Player** — browse courts, view details, book slots, and manage personal bookings.
- **Owner** — manage owned courts, add new courts, review bookings, and monitor revenue.

## Features

- Role-based authentication (login, register, forgot password)
- Court exploration with search and filtering
- Court detail view with available time slots
- Booking confirmation flow
- Owner dashboard for managing fields and bookings
- Profile and account settings
- Persistent session management with SharedPreferences

## Tech Stack

- **Framework:** Flutter
- **State Management:** Provider
- **Backend:** Supabase
- **Local Session Storage:** SharedPreferences
- **Password Hashing:** bcrypt
- **UI Components:** Material Design, Google Fonts

## Architecture Overview

The project follows a feature-based structure:

- `lib/features/auth` — authentication flow
- `lib/features/court` — court listing, details, booking logic
- `lib/features/owner` — owner dashboard and court management
- `lib/features/profile` — profile and account settings
- `lib/core` — shared services, configuration, theme, and widgets

The app initializes Supabase in `main()` and registers the main `ChangeNotifier` providers:

- `AuthViewModel`
- `CourtViewModel`
- `BookingViewModel`
- `OwnerViewModel`

## Prerequisites

Make sure you have Flutter installed:

- Flutter SDK (recommended: 3.11 or newer)
- Dart SDK (bundled with Flutter)
- Android/iOS/macOS/Web emulator or physical device for running the app

## Getting Started

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Ensure Supabase configuration is set correctly in `lib/core/config/supabase_config.dart`.

3. Run the app:

   ```bash
   flutter run
   ```

4. To run on a specific platform:

   ```bash
   flutter run -d android
   flutter run -d ios
   flutter run -d chrome
   flutter run -d windows
   ```

## Useful Commands

```bash
# Analyze the project
flutter analyze

# Run tests
flutter test

# Build Android APK
flutter build apk

# Build Windows desktop app
flutter build windows
```

## Backend Notes

- Authentication does not use Supabase Auth directly; it queries the `users` table and validates passwords using bcrypt.
- Session state is persisted locally using `SessionService`.
- Court images are expected to be stored in a Supabase Storage bucket named `fields` (with fallback behavior in the owner add-court flow).

## Project Structure

```text
lib/
  core/
    config/
    constants/
    services/
    widgets/
  features/
    auth/
    court/
    dashboard/
    owner/
    profile/
```
