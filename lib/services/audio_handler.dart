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
    _audioPlayer.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
        queueIndex: _currentIndex,
      ));
    });

    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
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
    if (_currentIndex < _songQueue.length - 1) {
      _currentIndex++;
      await playSongFromQueue(_songQueue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await playSongFromQueue(_songQueue[_currentIndex]);
    }
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
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    await _queueSubject.close();
    await super.stop();
  }
}
