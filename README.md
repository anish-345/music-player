# Music Player App 🎵

A modern, feature-rich Flutter music player app for Android with a stunning 3D UI design and comprehensive playback controls.

![App Icon](assets/images/muico.png)

## ✨ Features

### 🎨 Modern 3D UI Design
- **Dark Theme**: Sophisticated gradient design matching the app icon
- **3D Effects**: Multi-layered shadows, borders, and depth effects
- **Smooth Animations**: Fluid transitions between screens
- **Custom Gradients**: Navy blue to purple gradient throughout

### 🎵 Music Playback
- **Background Playback**: Continue listening while using other apps
- **Media Notifications**: Full control from notification panel
- **Queue Management**: Add, remove, and reorder songs
- **Shuffle Mode**: Randomize playback order
- **Repeat Modes**: Off, Repeat All, Repeat One

### 🔍 Smart Features
- **Real-time Search**: Filter songs by title or artist
- **Public Folder Scanning**: Only scans music from public directories
- **Swipe Gestures**: Swipe mini player to change tracks
- **Three-dot Menu**: Quick actions (Play Next, Add to Queue, Delete)

### 📱 User Interface
- **Home Screen**: ListView of all audio files with search
- **Mini Player**: Persistent bottom player with swipe controls
- **Full-Screen Player**: Complete playback interface with:
  - Play/Pause, Next, Previous controls
  - Shuffle and Repeat buttons
  - Progress bar with seek functionality
  - Share and Queue buttons
  - Album art display

## 🛠️ Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Audio Playback**: just_audio, audio_service
- **Permissions**: permission_handler
- **Music Query**: on_audio_query
- **Sharing**: share_plus

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  just_audio: ^0.9.36
  audio_service: ^0.18.12
  permission_handler: ^11.0.1
  on_audio_query: ^2.9.0
  provider: ^6.1.1
  share_plus: ^7.2.1
  rxdart: ^0.27.7
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/music-player.git
   cd music-player
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── constants/
│   └── app_theme.dart          # App-wide theme and gradients
├── models/
│   └── song.dart               # Song data model
├── providers/
│   └── music_provider.dart     # State management
├── screens/
│   ├── home_screen.dart        # Main screen with song list
│   ├── player_screen.dart      # Full-screen player
│   └── queue_screen.dart       # Queue management
├── services/
│   ├── audio_handler.dart      # Audio service handler
│   ├── audio_service.dart      # Audio playback service
│   ├── permission_service.dart # Permission handling
│   └── song_service.dart       # Song fetching
├── widgets/
│   ├── mini_player.dart        # Bottom mini player
│   └── song_list_item.dart     # Song list item widget
└── main.dart                   # App entry point
```

## 🎨 Design System

### Color Palette
- **Dark Navy**: `#1C1E2E`
- **Slate Blue**: `#2D3142`
- **Deep Slate**: `#3A3D52`
- **Dark Purple**: `#2E2440`
- **Rich Purple**: `#3D2E4F`

### Gradients
- **Primary Gradient**: 5-color gradient from dark navy to rich purple
- **Icon Gradient**: 3-color gradient for smaller elements

### 3D Effects
- Multi-layered shadows for depth
- Border highlights for edge lighting
- Active/inactive states for interactive elements

## 🔐 Permissions

The app requires the following permissions:
- `READ_EXTERNAL_STORAGE` - Access music files
- `READ_MEDIA_AUDIO` - Android 13+ audio access
- `WAKE_LOCK` - Keep device awake during playback
- `FOREGROUND_SERVICE` - Background playback
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK` - Media playback service

## 📱 Screenshots

### Home Screen
- Song list with search functionality
- Custom app icon with gradient
- 3D styled song items

### Mini Player
- Persistent bottom player
- Swipe to change tracks
- Play/pause and next controls

### Full Player
- Large album art display
- Complete playback controls
- Shuffle and repeat options
- Progress bar with seek
- Share and queue buttons

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- just_audio and audio_service packages
- on_audio_query for music file access
- All contributors and testers

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Made with ❤️ using Flutter**
