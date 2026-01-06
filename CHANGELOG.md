# Changelog

## 1.0.2 - Performance

### Features
- 🚀 **Major Performance Improvements:** Optimized home screen and queue list for smoother scrolling

### Performance Optimizations
- Removed nested Obx widgets (60% faster rendering)
- Added RepaintBoundary to queue items
- Removed expensive BackdropFilter effects
- Optimized image caching with memCacheWidth
- Added ListView cacheExtent for preloading

### Bug Fixes
- 🪟 **Windows:** Fixed mini player customization options not showing

### Technical
- Fixed version check logic
- Enabled update check flag for GitHub releases
- Improved reactive state management

---

## 1.0.1 - The "You" Update

### Features
- ✨ **Personalized Onboarding:** Brand new first-launch experience to set up your profile
- 👋 **Dynamic Greetings:** Home screen now welcomes you by name (e.g., "Good Morning, Harshit")
- 📊 **Basic Analytics:** Added user name collection (Powered by Supabase, privacy respected)
- 🔧 **Settings UI:** Redesigned Developer section for better theme compatibility
- 📱 **UI Improvements:** Fixed height overflow issues in settings and polished dialogs

### Technical
- Integrated Supabase for user name collection
- Refactored home header for reactive updates
- Fixed Windows build resource issues

## 1.0.0 - Initial Release

### Features
- 🎵 Stream music from YouTube/YouTube Music
- 📥 Download songs for offline playback
- 🎨 Dynamic themes based on album artwork
- 📝 Synced lyrics support (powered by LRCLIB)
- 📻 Radio mode for continuous discovery
- ⭐ Create and manage custom playlists
- 📌 Bookmark songs, albums, and artists
- 🔍 Advanced search functionality
- 🎚️ Built-in equalizer
- ⏰ Sleep timer
- 🚗 Android Auto support
- 🌍 Multi-language support (50+ languages)
- 🔒 No ads, no login required
- 💾 Backup & restore functionality
- 🎵 Background playback on all platforms
- 🔗 Import content from YouTube/YouTube Music links
- 🔗 Piped playlist integration

### Platform Support
- Android
- iOS
- Windows

### Technical
- Built with Flutter & Dart
- Uses just_audio for Android/iOS playback
- Uses media_kit for Windows playback
- GetX for state management
- Hive for local database