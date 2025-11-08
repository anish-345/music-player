import 'package:on_audio_query/on_audio_query.dart';
import '../models/song.dart';

class SongService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<Song>> fetchSongs() async {
    try {
      // Check permissions first
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }

      // Query songs from public external storage only
      final songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filter to only include songs from public directories
      final publicSongs = songs.where((song) {
        final path = song.data.toLowerCase();
        // Include only songs from common public music directories
        return path.contains('/music/') ||
            path.contains('/download/') ||
            path.contains('/downloads/') ||
            path.contains('/audio/') ||
            path.contains('/media/') ||
            path.contains('/sdcard/');
      }).toList();

      return publicSongs
          .map((song) => Song(
                id: song.id.toString(),
                title: song.title,
                artist: song.artist ?? 'Unknown Artist',
                albumArt: song.uri,
                path: song.data,
                duration: song.duration ?? 0,
              ))
          .toList();
    } catch (e) {
      // Error fetching songs
      return [];
    }
  }
}
