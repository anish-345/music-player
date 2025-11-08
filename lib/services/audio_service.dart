import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _queue = [];
  int _currentIndex = 0;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isNotEmpty ? _queue[_currentIndex] : null;

  Future<void> playSong(Song song, {List<Song>? newQueue}) async {
    if (newQueue != null) {
      _queue = newQueue;
      _currentIndex = _queue.indexOf(song);
    }
    await _audioPlayer.setFilePath(song.path);
    await _audioPlayer.play();
  }

  Future<void> playPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> playNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await playSong(_queue[_currentIndex]);
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await playSong(_queue[_currentIndex]);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void addToQueue(Song song) {
    _queue.add(song);
  }

  void addPlayNext(Song song) {
    _queue.insert(_currentIndex + 1, song);
  }

  void removeFromQueue(int index) {
    if (index < _queue.length) {
      _queue.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
