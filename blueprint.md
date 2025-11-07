
# Project Blueprint: Qtonz Music Player

## Overview

This document outlines the plan and progress for creating Qtonz, a modern, offline-first music player built with Flutter. The app will focus on a delightful user experience with a rich feature set.

## Core Features

- **Local File Playback**: Support for major audio formats (MP3, WAV, FLAC, AAC).
- **Smart Library**: Automatic organization of music by artist, album, genre, and folder.
- **Offline-first**: No internet dependency for core functionality.

## UX Hooks

- **Waveform Visualizer**: Animated audio visualizations.
- **Mood-based Themes**: UI colors adapt to album art.
- **Gesture Controls**: Swipe to skip, tap to pause.
- **Player Banner**: A persistent banner at the bottom showing the currently playing track and controls.

## Plan

### Phase 1: Foundation (Complete)

1.  **Project Setup**: Initialized project, added dependencies (`audioplayers`, `file_picker`, `provider`, `google_fonts`, `flutter_launcher_icons`), and created `blueprint.md`.
2.  **Basic UI Structure**: Implemented `ThemeProvider`, `MusicProvider`, a home screen, and the persistent player banner.
3.  **Core Functionality**: Implemented local file picking and basic audio playback (play, pause, seek).

### Phase 2: Library & Visuals

1.  **Smart Library**:
    *   Implement logic to scan and organize audio files.
    *   Display music in sorted lists (artist, album, etc.).
    *   **Folder View**: Allow users to browse music by their folder structure.
    *   **Playlist Creation**: Enable users to create and manage custom playlists.

2.  **Waveform Visualizer**:
    *   Integrate a waveform visualization widget.

### Phase 3: Polish & UX

1.  **Mood-based Themes**:
    *   Implement logic to extract colors from album art.
    *   Apply colors to the player UI.

2.  **Gesture Controls**:
    *   Add swipe and tap gestures to the player.

3.  **App Icon**:
    *   Design and generate app icons.
