# Transact Record

## Overview

**Transact Record** is a financial tracking mobile application designed to help users record, manage, and analyze their daily transactions with ease. The app enables seamless expense tracking, categorization, and collaboration for shared financial management.

## Features

- 📒 **Daily Transaction Logging** – Easily record income and expenses.
- 📂 **Personalized Books** – Organize transactions into different books (e.g., groceries, travel, etc.).
- 🤝 **Book Sharing & Collaboration** – Invite friends or family to contribute to shared expense tracking.
- 🔗 **Deep Linking for Shareable Books** – Easily share and access financial records.
- 📊 **Graphical Insights** – Visual representation of earnings and expenses.
- 📈 **Collection Target Tracking** – Set financial target goals for books (e.g. Due Books) and monitor collected progress in real-time with visual indicators.
- 🔍 **Advanced Search & Filters** – Quickly find past transactions.
- 🔔 **Instant Notifications** – Stay updated with transaction changes and book activity.

## Tech Stack

- **Frontend:** Flutter & Dart
- **Database:** Hive (Local Storage)
- **Cloud Services:** Google Firebase (Authentication & Real-time Sync)
- **Version Control:** GitHub

## Installation & Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/transact-record.git
   cd transact-record
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Run the application:**
   ```sh
   flutter run
   ```

### iOS Setup (Swift Package Manager)

This project uses Swift Package Manager (SPM) for iOS plugins. If you run into build errors related to target platform mismatch (e.g., `cloud-firestore` requires minimum platform version `15.0` but target supports `13.0`):

1. Open the workspace in Xcode: `open ios/Runner.xcworkspace`.
2. Under both the Project and Target settings for `Runner`, verify that the **Minimum Deployments / iOS Deployment Target** version is set to at least **15.0**.
3. Re-generate the local build configurations using:
   ```sh
   flutter clean
   mkdir -p build/ios/SourcePackages
   flutter pub get
   flutter build ios --config-only
   ```
   _Note: A known bug in Flutter's Swift Package Manager tooling causes `flutter pub get` to fail with an rsync directory error after `flutter clean` because the `build` directory is deleted. Creating the `build/ios/SourcePackages` parent directory manually before running `flutter pub get` bypasses this error._

## Download & Access

- **Play Store:** [Download Here](https://play.google.com/store/apps/details?id=com.imperial.transactRecord&hl=en)

## Contributing

We welcome contributions! Feel free to submit issues, feature requests, or pull requests.

## License

This project is licensed under the MIT License.

## Contact

For inquiries or collaborations, reach out at [your email] or visit [yourwebsite.com].
