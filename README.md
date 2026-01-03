<div align="center">

# 🎵 Sangeet

### Your Music, Your Way

*A beautiful, privacy-focused music client for Android, iOS, and Windows*

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Flutter](https://img.shields.io/badge/Flutter-3.1.5+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows-lightgrey)](https://github.com/heyharshit0x/Sangeet)
[![Website](https://img.shields.io/badge/Website-sangeet--official.vercel.app-4CAF50?style=flat&logo=google-chrome&logoColor=white)](https://sangeet-official.vercel.app/)

<!-- ![Sangeet Cover](cover.png) -->

[Website](https://sangeet-official.vercel.app/) • [Installation](#-installation) • [Features](#-features) • [Screenshots](#-screenshots) • [Building](#-building-from-source) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 🎧 **Playback & Audio**
- 🎵 Stream audio from publicly available sources
- 🔊 High-quality audio streaming with quality control
- 🎚️ Built-in equalizer for custom sound profiles
- 🔇 Skip silence feature
- 📻 Radio mode for continuous music discovery
- ⏰ Sleep timer for automatic playback stop
- 🔄 Shuffle, repeat, and queue management

### 🎨 **User Experience**
- 🌈 **Dynamic themes** that adapt to album artwork
- 🌓 Dark mode support
- 📱 Flexible UI: Switch between bottom and side navigation
- 🎭 Beautiful, modern interface
- 🌍 Multi-language support (50+ languages)
- ♿ Accessibility features

### 📚 **Library & Organization**
- ⭐ Create unlimited custom playlists
- 📌 Bookmark songs, albums, and artists
- 💾 Local caching where permitted
- 📊 Recently played history
- 🔍 Advanced search functionality

### 🎤 **Lyrics & Discovery**
- 📝 **Synced lyrics** support (powered by LRCLIB)
- 📜 Plain lyrics fallback
- 🔗 Import content via public playlist links
- 🔗 Piped playlist integration
- 🎯 Personalized recommendations

### 🚀 **Platform Features**
- 📱 **Android Auto** support
- 🎵 Background audio support
- 🔔 Media notification controls
- 🪟 Windows: System tray integration, SMTC support
- 🍎 iOS: Lock screen controls
- 💾 Backup & restore functionality

### 🔒 **Privacy & Freedom**
- ✅ **Privacy-focused**
- ✅ **No login required**
- ✅ **No data collection**
- ✅ **100% free and open-source**
- ✅ All data stored locally on your device

---

## 📥 Installation

**🌐 [Visit Official Website](https://sangeet-official.vercel.app/)**

### Android
- 📦 [Direct APK Download](https://github.com/heyharshit0x/Sangeet/releases/latest)

### iOS
- 📱 Build from source using Xcode (IPA not distributed directly)

### Windows
- 💻 [Windows Installer (.exe)](https://github.com/heyharshit0x/Sangeet/releases/latest)
- 📦 Portable version available

**Current Version:** 1.0.0 | [View Changelog](CHANGELOG.md)

---

## 📱 Screenshots

<div align="center">

*Screenshots coming soon - showcasing home screen, player, playlists, and settings*

</div>

---

## 🛠️ Building from Source

### Prerequisites
- Flutter SDK (3.1.5 or higher)
- Dart SDK
- Android Studio / Xcode / Visual Studio (for respective platforms)

### Clone the Repository
```bash
git clone https://github.com/heyharshit0x/Sangeet.git
cd Sangeet
```

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Windows
flutter run -d windows
```

### Build Release
```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ipa --release

# Windows
flutter build windows --release
```

---

## 🧩 Tech Stack

| Component | Technology |
|-----------|-----------|
| **Framework** | [Flutter](https://flutter.dev) |
| **Language** | Dart |
| **State Management** | GetX |
| **Audio Playback** | just_audio (Android/iOS), media_kit (Windows) |
| **Background Service** | audio_service |
| **Database** | Hive |
| **Lyrics** | LRCLIB API |

### Major Dependencies
- `just_audio` - Audio player for Android/iOS
- `media_kit` - Audio player for Windows
- `audio_service` - Background playback & media controls
- `get` - State management & dependency injection
- `hive` - Local database
- `cached_network_image` - Image caching
- `palette_generator` - Dynamic theme colors

---

## 🤝 Contributing

Contributions are welcome! Whether it's bug fixes, feature additions, or translations, we appreciate your help.

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Areas for Contribution
- 🐛 Bug fixes
- ✨ New features
- 🌍 Translations
- 📝 Documentation
- 🎨 UI/UX improvements

---

## ⚠️ Troubleshooting

### Network errors or content not loading
**Solution:** Check your internet connection and if still facing then raise an issue [here](https://github.com/heyharshit0x/Sangeet/issues).

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0**.

```
Sangeet is free software: you can redistribute it and/or modify it under the terms of 
the GNU General Public License as published by the Free Software Foundation, either 
version 3 of the License, or (at your option) any later version.
```

See [LICENSE](LICENSE) for full details.

---

## ⚖️ Disclaimer

```
Sangeet does not host, store, or redistribute copyrighted media.

All content is accessed from third-party sources, and users are responsible
for complying with the terms of service and local laws applicable to those platforms.

This project is not affiliated with, endorsed by, or associated with any
music content provider.
```

---

## 🙏 Credits & Acknowledgments

This project wouldn't be possible without these amazing resources:

### Inspiration & Resources
- 🎨 **Inspiration:** ViMusic and Harmony Music
- 📚 **Flutter Documentation:** [docs.flutter.dev](https://docs.flutter.dev/)
- 📝 **Lyrics:** [LRCLIB](https://lrclib.net)
- 🔗 **Playlists:** [Piped](https://piped.video)
- 📖 **Architecture:** Articles by [Suragch](https://suragch.medium.com/)

---

<div align="center">

### ⭐ Star this repo if you like Sangeet!

Made with ❤️ by Harshit

[Report Bug](https://github.com/heyharshit0x/Sangeet/issues) • [Request Feature](https://github.com/heyharshit0x/Sangeet/issues) • [Website](https://sangeet-official.vercel.app/)

</div>
Copyright (c) 2026 Harshit Gupta (@heyharshit0x)
Licensed under GPL-3.0.