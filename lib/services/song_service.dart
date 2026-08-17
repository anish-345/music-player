import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('[SongService] Error fetching songs: $e');
      return [];
    }
  }

  Future<bool> deleteSongFile(Song song) async {
    try {
      // For Android 11+, we can delete files we created without special permissions
      // For Android 10 and below, we need storage permission

      if (Platform.isAndroid) {
        final versionString = Platform.version.split(' ')[0];
        final version = int.parse(versionString);

        // Android 11+ (API 30) - use scoped storage
        if (version >= 30) {
          // Use MediaStore to delete - requires READ/WRITE_MEDIA_AUDIO
          final file = File(song.path);
          if (await file.exists()) {
            await file.delete();

            // Refresh media store
            try {
              await _audioQuery.scanMedia(song.path);
            } catch (e) {
              debugPrint('[SongService] Error scanning media: $e');
            }
            return true;
          }
          return false;
        }
      }

      // For older Android versions, try direct deletion
      final file = File(song.path);
      if (await file.exists()) {
        await file.delete();

        // Refresh media store
        if (Platform.isAndroid) {
          try {
            await _audioQuery.scanMedia(song.path);
          } catch (e) {
            debugPrint('[SongService] Error scanning media: $e');
          }
        }

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SongService] Error deleting file: $e');
      return false;
    }
  }
}
