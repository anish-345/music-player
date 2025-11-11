import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/audio_handler.dart';
import '../services/song_service.dart';
import '../services/playlist_service.dart';

export 'package:just_audio/just_audio.dart' show LoopMode;

class MusicProvider extends ChangeNotifier {
  final MusicAudioHandler _audioHandler;
  final SongService _songService = SongService();
  final PlaylistService _playlistService = PlaylistService();

  List<Song> _songs = [];
  List<Song> _filteredSongs = [];
  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Song> get songs => _searchQuery.isEmpty ? _songs : _filteredSongs;
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  AudioPlayer get audioPlayer => _audioHandler.audioPlayer;
  Song? get currentSong => _audioHandler.currentSong;
  List<Song> get queue => _audioHandler.songQueue;
  int get currentIndex => _audioHandler.currentIndex;
  String get searchQuery => _searchQuery;
  bool get isShuffled => _audioHandler.isShuffled;
  LoopMode get loopMode => _audioHandler.loopMode;

  MusicProvider(this._audioHandler) {
    // Only notify on actual state changes (playing/paused/stopped)
    _audioHandler.audioPlayer.playerStateStream.distinct().listen((_) {
      notifyListeners();
    });

    // Don't listen to position stream here - let widgets that need it subscribe directly
    // This reduces unnecessary rebuilds across the entire app
  }

  void searchSongs(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSongs = [];
    } else {
      _filteredSongs = _songs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artist.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    _songs = await _songService.fetchSongs();
    _playlists = await _playlistService.loadPlaylists();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    await _playlistService.createPlaylist(name);
    _playlists = await _playlistService.loadPlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _playlistService.deletePlaylist(playlistId);
    _playlists = await _playlistService.loadPlaylists();
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _playlistService.addSongToPlaylist(playlistId, songId);
    _playlists = await _playlistService.loadPlaylists();
    notifyListeners();
  }

  Future<void> addSongsToPlaylist(
      String playlistId, List<String> songIds) async {
    await _playlistService.addSongsToPlaylist(playlistId, songIds);
    _playlists = await _playlistService.loadPlaylists();
    notifyListeners();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _playlistService.removeSongFromPlaylist(playlistId, songId);
    _playlists = await _playlistService.loadPlaylists();
    notifyListeners();
  }

  List<Song> getPlaylistSongs(String playlistId) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    return _songs.where((song) => playlist.songIds.contains(song.id)).toList();
  }

  Future<void> playSong(Song song, {List<Song>? customQueue}) async {
    final queue = customQueue ?? _songs;
    await _audioHandler.playSongFromQueue(song, newQueue: queue);
    notifyListeners();
  }

  Future<void> playPlaylist(String playlistId) async {
    final playlistSongs = getPlaylistSongs(playlistId);
    if (playlistSongs.isNotEmpty) {
      await playSong(playlistSongs[0], customQueue: playlistSongs);
    }
  }

  Future<void> shufflePlaylist(String playlistId) async {
    final playlistSongs = getPlaylistSongs(playlistId);
    if (playlistSongs.isNotEmpty) {
      final shuffled = List<Song>.from(playlistSongs)..shuffle();
      await playSong(shuffled[0], customQueue: shuffled);
      if (!_audioHandler.isShuffled) {
        _audioHandler.toggleShuffle();
      }
    }
  }

  Future<void> playPause() async {
    if (_audioHandler.audioPlayer.playing) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    await _audioHandler.skipToNext();
    notifyListeners();
  }

  Future<void> playPrevious() async {
    await _audioHandler.skipToPrevious();
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioHandler.seek(position);
  }

  void addToQueue(Song song) {
    _audioHandler.addToQueue(song);
    notifyListeners();
  }

  void playNextInQueue(Song song) {
    _audioHandler.addPlayNext(song);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _audioHandler.removeFromQueue(index);
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _audioHandler.reorderQueue(oldIndex, newIndex);
    notifyListeners();
  }

  Future<bool> deleteSong(Song song) async {
    // Delete the actual file from device
    final deleted = await _songService.deleteSongFile(song);

    if (deleted) {
      // Remove from app state
      _songs.removeWhere((s) => s.id == song.id);
      _filteredSongs.removeWhere((s) => s.id == song.id);

      // Remove from all playlists
      for (var playlist in _playlists) {
        playlist.songIds.remove(song.id);
      }
      await _playlistService.savePlaylists(_playlists);

      // If currently playing, skip to next
      if (currentSong?.id == song.id) {
        await playNext();
      }

      // Remove from queue if present
      final queueIndex =
          _audioHandler.songQueue.indexWhere((s) => s.id == song.id);
      if (queueIndex != -1) {
        _audioHandler.removeFromQueue(queueIndex);
      }

      notifyListeners();
    }

    return deleted;
  }

  void toggleShuffle() {
    _audioHandler.toggleShuffle();
    notifyListeners();
  }

  void toggleRepeat() {
    _audioHandler.toggleRepeatMode();
    notifyListeners();
  }

  void sortSongs(String sortBy) {
    switch (sortBy) {
      case 'title':
        _songs.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'artist':
        _songs.sort(
            (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case 'date':
        _songs.sort(
            (a, b) => b.id.compareTo(a.id)); // Assuming id represents date
        break;
    }

    // Also sort filtered songs if search is active
    if (_searchQuery.isNotEmpty) {
      switch (sortBy) {
        case 'title':
          _filteredSongs.sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
        case 'artist':
          _filteredSongs.sort((a, b) =>
              a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
          break;
        case 'date':
          _filteredSongs.sort((a, b) => b.id.compareTo(a.id));
          break;
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _audioHandler.stop();
    super.dispose();
  }
}
