import 'package:shared_preferences/shared_preferences.dart';

class PlaybackPersistenceService {
  static const String _currentSongIdKey = 'current_song_id';
  static const String _queueIdsKey = 'queue_ids';
  static const String _positionMsKey = 'last_position_ms';
  static const String _shuffleKey = 'is_shuffled';
  static const String _loopModeKey = 'loop_mode';

  Future<void> savePlaybackState({
    required String? currentSongId,
    required List<String> queueIds,
    required int positionMs,
    required bool isShuffled,
    required String loopMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (currentSongId != null) {
      await prefs.setString(_currentSongIdKey, currentSongId);
    } else {
      await prefs.remove(_currentSongIdKey);
    }
    await prefs.setStringList(_queueIdsKey, queueIds);
    await prefs.setInt(_positionMsKey, positionMs);
    await prefs.setBool(_shuffleKey, isShuffled);
    await prefs.setString(_loopModeKey, loopMode);
  }

  Future<Map<String, dynamic>> loadPlaybackState() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'currentSongId': prefs.getString(_currentSongIdKey),
      'queueIds': prefs.getStringList(_queueIdsKey) ?? [],
      'positionMs': prefs.getInt(_positionMsKey) ?? 0,
      'isShuffled': prefs.getBool(_shuffleKey) ?? false,
      'loopMode': prefs.getString(_loopModeKey) ?? 'off',
    };
  }
}
