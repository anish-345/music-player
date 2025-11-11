import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<bool> deleteSongFile(Song song) async {
    try {
      // Request storage permissions
      if (Platform.isAndroid) {
        // For Android 11+ (API 30+), we need MANAGE_EXTERNAL_STORAGE
        if (await Permission.manageExternalStorage.isDenied) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            // Try with regular storage permission
            final storageStatus = await Permission.storage.request();
            if (!storageStatus.isGranted) {
              return false;
            }
          }
        }
      }

      // Delete the file
      final file = File(song.path);
      if (await file.exists()) {
        await file.delete();

        // Refresh media store on Android
        if (Platform.isAndroid) {
          await _audioQuery.scanMedia(song.path);
        }

        return true;
      }
      return false;
    } catch (e) {
      // Error deleting file
      return false;
    }
  }
}
