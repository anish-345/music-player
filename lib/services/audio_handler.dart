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
      _updatePlaybackState(state);

      // Auto-play next song when current song completes
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });

    // Update position and duration for progress bar
    _audioPlayer.positionStream.listen((position) {
      final duration = _audioPlayer.duration ?? Duration.zero;
      if (playbackState.hasValue) {
        playbackState.add(playbackState.value.copyWith(
          updatePosition: position,
          bufferedPosition: duration,
        ));
      }
    });

    // Update duration when it changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null && playbackState.hasValue) {
        playbackState.add(playbackState.value.copyWith(
          bufferedPosition: duration,
        ));
      }
    });
  }

  void _updatePlaybackState(PlayerState state) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        state.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        // Shuffle control
        const MediaControl(
          androidIcon: 'drawable/ic_shuffle',
          label: 'Shuffle',
          action: MediaAction.custom,
          customAction: CustomMediaAction(name: 'shuffle'),
        ),
        // Repeat control
        MediaControl(
          androidIcon: _loopMode == LoopMode.one
              ? 'drawable/ic_repeat_one'
              : 'drawable/ic_repeat',
          label: 'Repeat',
          action: MediaAction.custom,
          customAction: const CustomMediaAction(name: 'repeat'),
        ),
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
      shuffleMode: _isShuffled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: _loopMode == LoopMode.one
          ? AudioServiceRepeatMode.one
          : _loopMode == LoopMode.all
              ? AudioServiceRepeatMode.all
              : AudioServiceRepeatMode.none,
    ));
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

  Future<void> playSongFromQueue(Song song,
      {List<Song>? newQueue, bool shouldPlay = true}) async {
    try {
      if (newQueue != null) {
        _songQueue = List<Song>.from(newQueue);
        _currentIndex = _songQueue.indexOf(song);

        final mediaItems = _songQueue
            .map((s) => MediaItem(
                  id: s.id,
                  title: s.title,
                  artist: s.artist,
                  duration: Duration(milliseconds: s.duration),
                  artUri: Uri.parse(
                      'android.resource://avionti.music_player/mipmap/ic_launcher'),
                ))
            .toList();

        _queueSubject.add(mediaItems);
      } else {
        _currentIndex = _songQueue.indexOf(song);
      }

      final currentMediaItem = MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        duration: Duration(milliseconds: song.duration),
        artUri: Uri.parse(
            'android.resource://avionti.music_player/mipmap/ic_launcher'),
        extras: {
          'hideMediaRoute': true,
        },
      );

      mediaItem.add(currentMediaItem);

      await _audioPlayer.setFilePath(song.path);
      if (shouldPlay) {
        await _audioPlayer.play();
      }
    } catch (e) {
      // Error playing song - try to skip to next song if available
      if (shouldPlay &&
          _songQueue.length > 1 &&
          _currentIndex < _songQueue.length - 1) {
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
              duration: Duration(milliseconds: s.duration),
              artUri: Uri.parse(
                  'android.resource://avionti.music_player/mipmap/ic_launcher'),
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
              duration: Duration(milliseconds: s.duration),
              artUri: Uri.parse(
                  'android.resource://avionti.music_player/mipmap/ic_launcher'),
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
                duration: Duration(milliseconds: s.duration),
                artUri: Uri.parse(
                    'android.resource://avionti.music_player/mipmap/ic_launcher'),
              ))
          .toList();
      _queueSubject.add(mediaItems);
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Don't allow reordering the currently playing song
    if (oldIndex == _currentIndex) {
      return;
    }

    final song = _songQueue.removeAt(oldIndex);
    _songQueue.insert(newIndex, song);

    // Update current index if needed
    if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    final mediaItems = _songQueue
        .map((s) => MediaItem(
              id: s.id,
              title: s.title,
              artist: s.artist,
              duration: Duration(milliseconds: s.duration),
              artUri: Uri.parse(
                  'android.resource://avionti.music_player/mipmap/ic_launcher'),
            ))
        .toList();
    _queueSubject.add(mediaItems);
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
    // Update notification controls
    final currentState = _audioPlayer.playerState;
    _updatePlaybackState(currentState);
  }

  void toggleRepeatMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        // Don't set loop mode on audio player - we handle it manually
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        // Set loop mode only for repeat one
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        // Turn off loop mode
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    // Update notification controls
    final currentState = _audioPlayer.playerState;
    _updatePlaybackState(currentState);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'shuffle':
        toggleShuffle();
        break;
      case 'repeat':
        toggleRepeatMode();
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
