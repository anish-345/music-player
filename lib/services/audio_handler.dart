import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song.dart';

class MusicAudioHandler extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final BehaviorSubject<List<MediaItem>> _queueSubject =
      BehaviorSubject.seeded([]);
  List<Song> _songQueue = [];
  List<Song> _originalQueue = [];
  int _currentIndex = 0;
  bool _isShuffled = false;
  LoopMode _loopMode = LoopMode.off;

  MusicAudioHandler() {
    _init();
  }

  void _init() {
    // Only update on actual state changes, not every event
    _audioPlayer.playerStateStream.distinct().listen((state) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          state.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[state.processingState]!,
        playing: state.playing,
        queueIndex: _currentIndex,
      ));
    });

    // Throttle position updates to once per second to save battery
    _audioPlayer.positionStream
        .throttleTime(const Duration(seconds: 1))
        .listen((position) {
      if (playbackState.hasValue) {
        playbackState.add(playbackState.value.copyWith(
          updatePosition: position,
        ));
      }
    });
  }

  @override
  BehaviorSubject<List<MediaItem>> get queue => _queueSubject;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get songQueue => _songQueue;
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _songQueue.isNotEmpty ? _songQueue[_currentIndex] : null;
  bool get isShuffled => _isShuffled;
  LoopMode get loopMode => _loopMode;

  Future<void> playSongFromQueue(Song song, {List<Song>? newQueue}) async {
    try {
      if (newQueue != null) {
        _songQueue = newQueue;
        _currentIndex = _songQueue.indexOf(song);

        final mediaItems = _songQueue
            .map((s) => MediaItem(
                  id: s.id,
                  title: s.title,
                  artist: s.artist,
                  artUri: Uri.parse('asset:///assets/images/muico.png'),
                ))
            .toList();

        _queueSubject.add(mediaItems);
      }

      final currentMediaItem = MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        artUri: Uri.parse('asset:///assets/images/muico.png'),
      );

      mediaItem.add(currentMediaItem);

      await _audioPlayer.setFilePath(song.path);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing song: $e');
      // Try to skip to next song if available
      if (_songQueue.length > 1 && _currentIndex < _songQueue.length - 1) {
        await skipToNext();
      }
    }
  }

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> skipToNext() async {
    if (_songQueue.isEmpty) return;

    if (_currentIndex < _songQueue.length - 1) {
      _currentIndex++;
    } else if (_loopMode == LoopMode.all) {
      // When repeat queue is on and at last song, go to first song
      _currentIndex = 0;
    } else {
      // At last song and repeat is off, stay at last song
      return;
    }
    await playSongFromQueue(_songQueue[_currentIndex]);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_songQueue.isEmpty) return;

    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_loopMode == LoopMode.all) {
      // When repeat queue is on and at first song, go to last song
      _currentIndex = _songQueue.length - 1;
    } else {
      // At first song and repeat is off, stay at first song
      return;
    }
    await playSongFromQueue(_songQueue[_currentIndex]);
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void addToQueue(Song song) {
    _songQueue.add(song);
    final mediaItems = _songQueue
        .map((s) => MediaItem(
              id: s.id,
              title: s.title,
              artist: s.artist,
              artUri: Uri.parse('asset:///assets/images/muico.png'),
            ))
        .toList();
    _queueSubject.add(mediaItems);
  }

  void addPlayNext(Song song) {
    _songQueue.insert(_currentIndex + 1, song);
    final mediaItems = _songQueue
        .map((s) => MediaItem(
              id: s.id,
              title: s.title,
              artist: s.artist,
              artUri: Uri.parse('asset:///assets/images/muico.png'),
            ))
        .toList();
    _queueSubject.add(mediaItems);
  }

  void removeFromQueue(int index) {
    if (index < _songQueue.length) {
      _songQueue.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      }
      final mediaItems = _songQueue
          .map((s) => MediaItem(
                id: s.id,
                title: s.title,
                artist: s.artist,
                artUri: Uri.parse('asset:///assets/images/muico.png'),
              ))
          .toList();
      _queueSubject.add(mediaItems);
    }
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _originalQueue = List.from(_songQueue);
      final currentSong = _songQueue[_currentIndex];
      _songQueue.shuffle();
      _currentIndex = _songQueue.indexOf(currentSong);
    } else {
      final currentSong = _songQueue[_currentIndex];
      _songQueue = List.from(_originalQueue);
      _currentIndex = _songQueue.indexOf(currentSong);
    }
  }

  void toggleRepeatMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        _audioPlayer.setLoopMode(_loopMode);
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        _audioPlayer.setLoopMode(_loopMode);
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        _audioPlayer.setLoopMode(_loopMode);
        break;
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    // Stop playback when app is swiped away from recent apps
    await stop();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    await _queueSubject.close();
    await super.stop();
  }
}
