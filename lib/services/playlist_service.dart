import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';

class PlaylistService {
  static const String _playlistsKey = 'playlists';

  Future<List<Playlist>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getString(_playlistsKey);

    if (playlistsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(playlistsJson);
    return decoded.map((json) => Playlist.fromJson(json)).toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = jsonEncode(
      playlists.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_playlistsKey, playlistsJson);
  }

  Future<void> createPlaylist(String name) async {
    final playlists = await loadPlaylists();
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    playlists.add(newPlaylist);
    await savePlaylists(playlists);
  }

  Future<void> deletePlaylist(String playlistId) async {
    final playlists = await loadPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await savePlaylists(playlists);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlists = await loadPlaylists();
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    if (!playlist.songIds.contains(songId)) {
      playlist.songIds.add(songId);
      await savePlaylists(playlists);
    }
  }

  Future<void> addSongsToPlaylist(
      String playlistId, List<String> songIds) async {
    final playlists = await loadPlaylists();
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    for (final songId in songIds) {
      if (!playlist.songIds.contains(songId)) {
        playlist.songIds.add(songId);
      }
    }
    await savePlaylists(playlists);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlists = await loadPlaylists();
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    playlist.songIds.remove(songId);
    await savePlaylists(playlists);
  }
}
