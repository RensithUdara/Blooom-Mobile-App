<p align="center">
  <img src="assets/app-logo.png" alt="Blooom logo" width="120" />
</p>

# 🌸 Blooom

Blooom is a Flutter menstrual health companion app focused on private, device-only cycle tracking. It helps users log periods, follow wellness patterns, view predictions, see charts, add reminders, and protect access with a local app lock.

## ✨ App Overview

Blooom includes:

- 🌺 Splash screen with Blooom branding.
- 🧭 Three-screen onboarding flow.
- 🎨 Rose and white visual theme with dark theme support.
- 🏠 Home dashboard with current cycle day, phase, next period, ovulation, cycle length, and period length.
- 🩸 Period logging with start date, end date, flow intensity, and notes.
- 🌿 Daily wellness logging for mood, symptoms, weight, temperature, sleep, water, energy, intimacy, and notes.
- 📅 Calendar screen with period, predicted period, fertile window, and ovulation highlights.
- 📊 Insights screen with bar, pie, and line charts.
- 👤 Profile screen with editable name and birthday.
- 🔔 In-app local notifications for predicted period reminders.
- 🗓️ Calendar export for predicted period events.
- 🔐 App lock using device authentication or a Blooom PIN.
- 🗑️ Delete confirmation before removing period records.

## 🔒 Privacy

Blooom is currently designed for local-device use only. Cycle, wellness, profile, lock, reminder, and prediction data are stored on the user's device. There is no account system, cloud sync, backend API, or remote database in this stage.

The Blooom PIN is not stored as plain text. The app saves a local SHA-256 hash for PIN verification.

## 🏗️ Architecture

The app follows an MVVM-style structure.

```text
lib/
  app/
    blooom_app.dart
  core/
    constants/
    theme/
    utils/
  data/
    models/
    repositories/
    services/
  presentation/
    pages/
    viewmodels/
    widgets/
  main.dart
```

### 🧩 Layers

- `data/models`: Local data models such as period entries, wellness logs, and profile settings.
- `data/services`: SQLite, local notification, calendar export, and authentication services.
- `data/repositories`: Repository layer for reading and writing app data.
- `presentation/viewmodels`: App state and business logic exposed to the UI.
- `presentation/pages`: Main screens, startup flow, onboarding, logs, settings, and sheets.
- `presentation/widgets`: Reusable UI widgets, charts, calendar, cards, and animations.
- `core`: Theme, constants, and date utilities.

## 🚀 Main Features

### 🏠 Cycle Dashboard

The home screen shows:

- Current cycle day.
- Current phase.
- Days until predicted period.
- Predicted ovulation date.
- Average cycle length.
- Average period length.
- Smart insight summary.

### 📅 Calendar

The calendar highlights:

- Logged period days.
- Predicted period days.
- Fertile window.
- Ovulation day.
- Today.

It also includes a legend and an option to export the predicted period to the device calendar.

### 📝 Logs

Users can add:

- Period logs.
- Daily wellness logs.

Period logs can be deleted only after a confirmation dialog.

### 📊 Insights

Charts are powered by `fl_chart`:

- Bar chart for cycle length trends.
- Pie chart for symptom distribution.
- Line chart for energy trends.

Charts show empty states until the user logs enough real data.

### 🔐 App Lock

The Profile screen includes an App Lock setup flow:

- Face ID or device face unlock.
- Fingerprint.
- Device PIN/pattern/password through system authentication.
- Blooom PIN.

Startup routing:

```text
Splash -> Dashboard
Splash -> Device authentication -> Dashboard
Splash -> Blooom PIN page -> Dashboard
```

If no lock is configured, the app opens normally after splash/onboarding.

### 🔔 Notifications

The app schedules local period reminders on-device using `flutter_local_notifications`.

### 🗓️ Calendar Export

Predicted period events can be sent to the device calendar using `add_2_calendar`. The app shows feedback when the calendar app is opened or unavailable.

## 💾 Local Database

The app uses SQLite through `sqflite`.

Current tables:

- `periods`
- `wellness_logs`
- `profile_settings`

The database migration code checks existing columns before adding new ones, so development builds can upgrade safely without duplicate-column crashes.

## 📦 Important Dependencies

- `sqflite`: Local SQLite storage.
- `path`: Database path handling.
- `intl`: Date formatting.
- `fl_chart`: Bar, pie, and line charts.
- `flutter_local_notifications`: In-app local reminders.
- `timezone`: Notification scheduling support.
- `add_2_calendar`: Device calendar event export.
- `local_auth`: Device biometric and credential authentication.
- `crypto`: PIN hashing.

## 🖼️ Assets

Main logo:

```text
assets/app-logo.png
```

The logo is used in:

- Splash screen.
- Onboarding.
- Home/Profile UI.
- Launcher icon assets.
- Web manifest icons.

## 🤖 Android Notes

Android is configured for:

- Notification permission.
- Boot receiver support for scheduled notifications.
- Biometric/device authentication.
- Calendar insert intent visibility.
- Java core library desugaring for notification scheduling.

`MainActivity` extends `FlutterFragmentActivity` because `local_auth` requires fragment activity support on Android.

## 🍎 iOS Notes

`Info.plist` includes Face ID usage text for local app lock.

## ▶️ Run The App

```powershell
flutter pub get
flutter run
```

After native configuration changes, use:

```powershell
flutter clean
flutter pub get
flutter run
```

## ✅ Test And Analyze

```powershell
dart analyze
flutter test
```

Current tests include:

- Logo smoke test.
- Calendar widget regression test for month grids with leading blank cells.

## 🛠️ Development Status

Current stage:

- 📱 Local-only mobile app.
- 💾 SQLite-based storage.
- 🚫 No backend.
- 🚫 No cloud sync.
- 🚫 No user account system.

Planned future improvements may include:

- 📤 Data export/import.
- ⚙️ More cycle prediction settings.
- 🔔 More notification customization.
- ☁️ Optional cloud backup.
- 📈 More detailed reports.
