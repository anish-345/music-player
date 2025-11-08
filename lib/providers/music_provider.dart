import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/audio_handler.dart';
import '../services/song_service.dart';

export 'package:just_audio/just_audio.dart' show LoopMode;

class MusicProvider extends ChangeNotifier {
  final MusicAudioHandler _audioHandler;
  final SongService _songService = SongService();

  List<Song> _songs = [];
  List<Song> _filteredSongs = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Song> get songs => _searchQuery.isEmpty ? _songs : _filteredSongs;
  bool get isLoading => _isLoading;
  AudioPlayer get audioPlayer => _audioHandler.audioPlayer;
  Song? get currentSong => _audioHandler.currentSong;
  List<Song> get queue => _audioHandler.songQueue;
  int get currentIndex => _audioHandler.currentIndex;
  String get searchQuery => _searchQuery;
  bool get isShuffled => _audioHandler.isShuffled;
  LoopMode get loopMode => _audioHandler.loopMode;

  MusicProvider(this._audioHandler) {
    _audioHandler.audioPlayer.playerStateStream.listen((_) {
      notifyListeners();
    });

    _audioHandler.audioPlayer.positionStream.listen((_) {
      notifyListeners();
    });
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

    _isLoading = false;
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    await _audioHandler.playSongFromQueue(song, newQueue: _songs);
    notifyListeners();
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

  void deleteSong(Song song) {
    _songs.removeWhere((s) => s.id == song.id);
    _filteredSongs.removeWhere((s) => s.id == song.id);
    notifyListeners();
  }

  void toggleShuffle() {
    _audioHandler.toggleShuffle();
    notifyListeners();
  }

  void toggleRepeat() {
    _audioHandler.toggleRepeatMode();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioHandler.stop();
    super.dispose();
  }
}
