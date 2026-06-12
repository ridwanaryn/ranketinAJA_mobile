# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on a specific device
flutter run -d windows   # or: android, ios, chrome

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/some_test.dart

# Build
flutter build apk          # Android
flutter build windows      # Windows
```

## Architecture

**raketinAJA** is a Flutter sports court booking app (badminton, padel, etc.) using **Provider** for state management and **Supabase** as the backend.

### Layer structure (per feature)

Each feature under `lib/features/` follows this layered pattern:

```
data/
  datasources/   ← direct Supabase SQL calls
  repositories/  ← business logic + error wrapping over datasources
  models/        ← plain Dart data classes with fromMap() factory
presentation/
  viewmodels/    ← ChangeNotifier, consumes repositories, holds UI state
  pages/         ← Flutter widgets, consume viewmodels via Provider
```

### Features

- **auth** — login, register, forgot password. Uses `bcrypt` for password hashing. Auth does NOT use Supabase Auth — it queries the `users` table directly and persists session state via `SessionService` (SharedPreferences).
- **court** — explore/browse courts, view detail, book a slot. `CourtViewModel` owns selection state (selected court, date, time slot) that `ConfirmationPage` reads to complete checkout.
- **owner** — dashboard for court owners to view their fields, bookings, and revenue.

### Core services

- `SupabaseService` (`lib/core/services/supabase_service.dart`) — initializes Supabase and exposes a singleton `client`. Called once in `main()` before `runApp`.
- `SessionService` (`lib/core/services/session_service.dart`) — persists user session (id, email, name, role) in SharedPreferences. `AuthViewModel.restoreSession()` is called at startup.
- Supabase credentials live in `lib/core/config/supabase_config.dart`.

### State management wiring

Four `ChangeNotifierProvider`s are registered at the root (`main.dart`):
- `AuthViewModel` — current user, login/register/logout
- `CourtViewModel` — court list, filters, and booking selection state
- `BookingViewModel` — booking creation and booked-slot availability checks
- `OwnerViewModel` — owner's courts and bookings

### Database tables (Supabase)

- `users` — id, name, email, phone, password (bcrypt), role (`player` | `owner`)
- `fields` — id, owner_id (→ users), name, sport_type, price_per_hour, capacity, is_indoor, features (array), description, location, image_url, status
- `bookings` — id, user_id (→ users), field_id (→ fields), booking_date, start_time, end_time, total_price, status
- `reviews` — field_id, rating (aggregated in `CourtRemoteDataSource` since there's no DB-side avg)

### Routing

Named routes declared in `MyApp` (`main.dart`). Navigation between court detail → confirmation relies on `CourtViewModel` carrying selection state rather than route arguments.

### bcrypt note

The `$2y$` prefix (PHP-style hash) is normalized to `$2a$` before verification in `AuthRemoteDataSource.verifyPassword()` to ensure compatibility with the Dart `bcrypt` package.
