import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../providers/music_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/song_list_item.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildPlayControls(context),
              Expanded(
                child: Consumer<MusicProvider>(
                  builder: (context, musicProvider, child) {
                    final songs = musicProvider.getPlaylistSongs(playlist.id);

                    if (songs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No songs in this playlist',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.iconGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppTheme.elevated3DShadow,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddSongsDialog(context, musicProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                icon: const Icon(Icons.add,
                                    color: AppTheme.primaryTextColor),
                                label: const Text(
                                  'Add Songs',
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 16 + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        return SongListItem(song: songs[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          final songs = musicProvider.getPlaylistSongs(playlist.id);
          if (songs.isNotEmpty) {
            return Container(
              decoration: BoxDecoration(
                gradient: AppTheme.iconGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.elevated3DShadow,
              ),
              child: FloatingActionButton(
                onPressed: () => _showAddSongsDialog(context, musicProvider),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: AppTheme.primaryTextColor),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddSongsDialog(BuildContext context, MusicProvider musicProvider) {
    final allSongs = musicProvider.songs;
    final playlistSongIds = playlist.songIds;
    final availableSongs =
        allSongs.where((song) => !playlistSongIds.contains(song.id)).toList();

    if (availableSongs.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add Songs to Playlist',
            style: TextStyle(color: AppTheme.primaryTextColor)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableSongs.length,
            itemBuilder: (context, index) {
              final song = availableSongs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/muico.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.music_note,
                              color: AppTheme.primaryTextColor, size: 20);
                        },
                      ),
                    ),
                  ),
                  title: Text(song.title,
                      style: const TextStyle(
                          color: AppTheme.primaryTextColor, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(song.artist,
                      style: const TextStyle(
                          color: AppTheme.secondaryTextColor, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryTextColor),
                    onPressed: () {
                      musicProvider.addSongToPlaylist(playlist.id, song.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: AppTheme.secondaryTextColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.arrow_back, color: AppTheme.primaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              playlist.name,
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayControls(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final songs = musicProvider.getPlaylistSongs(playlist.id);

        if (songs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.card3DDecoration,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.iconGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.button3DShadow,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Play all songs in playlist
                      musicProvider.playPlaylist(playlist.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.play_arrow,
                        color: AppTheme.primaryTextColor),
                    label: const Text(
                      'Play All',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.iconGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.button3DShadow,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Shuffle and play playlist
                      musicProvider.shufflePlaylist(playlist.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.shuffle,
                        color: AppTheme.primaryTextColor),
                    label: const Text(
                      'Shuffle',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
