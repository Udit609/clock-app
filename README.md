# Alarm Clock App

### Overview
The **Alarm Clock App** is a feature-rich alarm management application built using Flutter. It allows users to schedule alarms and receive fullscreen alarm notifications. The app uses **SQLite** database to persist alarm data, **Provider** for state management and **Awesome Notifications** for notification management, enabling alarms to trigger even when the screen is locked. The project structure and UI were inspired by the [flutter_alarm_clock](https://github.com/afzalali15/flutter_alarm_clock) repository.

<img src="https://github.com/user-attachments/assets/86951068-983f-4795-baa5-9fa7e22be2fb" width="325" height="600" alt="clock_screen"> <img src="https://github.com/user-attachments/assets/f0f97ceb-ce38-4af6-b003-9bc83e74133d" width="325" height="600" alt="alarm_screen"> <img src="https://github.com/user-attachments/assets/85f44738-acf8-4da2-8b7e-eb77e69ce3b5" width="325" height="600" alt="fullscreen_notification">




### Features
- **Create and Edit Alarms**: Add and update alarms with custom labels and times.
- **Full-Screen Alarm Notifications**: Fullscreen notifications appear when an alarm rings, with options to stop the alarm.
- **Repeat Alarms**: Schedule alarms for specific days of the week with repeat functionality.
- **State Management**: The state of the app is managed using the provider package.
- **Persistent Storage**: Alarms are stored in an SQLite database, ensuring data is preserved across app restarts.
- **Alarm Management**: Easily delete or modify scheduled alarms.

## Getting Started

### Prerequisites
To run this project, ensure you have the following:

- **Flutter SDK**: version >= 3.2.6
- **Dart SDK**: version >= 3.2.6 < 4.0.0

### Installation
1. **Clone the repository**:

   ```
   git clone https://github.com/Udit609/clock-app.git
   cd clock-app
   ```
2. **Install dependencies:**:

   ```
   flutter pub get
   ```
3. **Run the app**:

   ```
   flutter run
   ```
### Dependencies
This app relies on the following dependencies:

- [**intl**](https://pub.dev/packages/intl): For handling date and time formatting.
- [**sqflite**](https://pub.dev/packages/sqflite): SQLite plugin for Flutter.
- [**path**](https://pub.dev/packages/path): For manipulating file paths.
- [**awesome_notifications**](https://pub.dev/packages/awesome_notifications): For managing notifications.
- [**provider**](https://pub.dev/packages/provider): For state management.
- [**permission_handler**](https://pub.dev/packages/permission_handler): To handle permission requests.

### Project Structure
- **`lib/Screens`**: This directory contains the UI screens of the app
- **`lib/helpers/alarm_helper.dart`**: Contains the AlarmHelper class responsible for interacting with the SQLite database, managing CRUD operations (Create, Read, Update, Delete) for alarms.
- **`lib/helpers/notification_helper.dart`**: Handles scheduling, rescheduling, and cancelling alarm notifications using the Awesome Notifications plugin.
- **`lib/controllers/notification_controller.dart`**: Contains methods to handle user actions on notifications (e.g., stopping an alarm) and updating the database when notifications are dismissed or triggered.
- **`lib/utils/screen_lock_checker.dart`**: Provides utilities to check if the screen is locked, ensuring that the app triggers fullscreen notifications while the phone is locked.

### Customization
#### Adding Custom Sounds
Add your custom sounds to the `assets/sounds/` directory and ensure they are listed in the `pubspec.yaml` file.

#### Fonts
This project uses the Avenir font, included in the `assets/fonts/` directory. You can customize fonts by modifying the `pubspec.yaml` file.

### Notifications
Notifications are managed by **Awesome Notifications**. When an alarm is triggered, the app sends a fullscreen notification with a **Stop** button. The alarm will continue ringing until the user interacts with the notification.

### Database
Alarms are stored in a local SQLite database. The database contains information about the alarm such as the title, time, days scheduled, notification ID, and whether the alarm is pending.
