import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../constants/app_theme.dart';
import '../screens/player_screen.dart';

class SongListItem extends StatelessWidget {
  final Song song;

  const SongListItem({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      height: 70,
      decoration: AppTheme.card3DDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Play the song directly - no interstitial for simple song selection
            await musicProvider.playSong(song);
            if (!context.mounted) return;

            // Navigate to player screen immediately
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlayerScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppTheme.iconRadius),
                    border: Border.all(
                      color: Colors.white.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/muico.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.music_note,
                          color: AppTheme.primaryTextColor,
                          size: 28,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 20,
                  color: Colors.transparent,
                  onSelected: (value) {
                    switch (value) {
                      case 'play_next':
                        musicProvider.playNextInQueue(song);
                        break;
                      case 'add_queue':
                        musicProvider.addToQueue(song);
                        break;
                      case 'add_playlist':
                        _showAddToPlaylistDialog(context, musicProvider, song);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, musicProvider);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'play_next',
                      child: Container(
                        decoration: AppTheme.popup3DDecoration,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: const Row(
                          children: [
                            Icon(Icons.playlist_play,
                                color: AppTheme.primaryTextColor),
                            SizedBox(width: 12),
                            Text('Play Next',
                                style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'add_queue',
                      child: Container(
                        decoration: AppTheme.popup3DDecoration,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.queue_music,
                                color: AppTheme.primaryTextColor),
                            SizedBox(width: 12),
                            Text('Add to Queue',
                                style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'add_playlist',
                      child: Container(
                        decoration: AppTheme.popup3DDecoration,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.playlist_add,
                                color: AppTheme.primaryTextColor),
                            SizedBox(width: 12),
                            Text('Add to Playlist',
                                style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade900, Colors.red.shade700],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.elevated3DShadow,
                          border: Border.all(
                            color: Colors.red.withAlpha(30),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Delete',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(
      BuildContext context, MusicProvider musicProvider, Song song) {
    final playlists = musicProvider.playlists;

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No playlists yet. Create one first!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add to Playlist',
            style: TextStyle(color: AppTheme.primaryTextColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                leading: const Icon(Icons.playlist_play,
                    color: AppTheme.primaryTextColor),
                title: Text(playlist.name,
                    style: const TextStyle(color: AppTheme.primaryTextColor)),
                onTap: () {
                  musicProvider.addSongToPlaylist(playlist.id, song.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to ${playlist.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.secondaryTextColor)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, MusicProvider musicProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Delete Song?',
                style: TextStyle(color: AppTheme.primaryTextColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete this song from your device?',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withAlpha(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppTheme.secondaryTextColor, fontSize: 16)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppTheme.button3DShadow,
            ),
            child: TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Deleting...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                final deleted = await musicProvider.deleteSong(song);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        deleted
                            ? '✓ Song deleted successfully'
                            : '✗ Failed to delete. Grant storage permission in Settings.',
                      ),
                      backgroundColor:
                          deleted ? Colors.green.shade700 : Colors.red.shade700,
                      duration: const Duration(seconds: 3),
                      action: deleted
                          ? null
                          : SnackBarAction(
                              label: 'Settings',
                              textColor: Colors.white,
                              onPressed: () => openAppSettings(),
                            ),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text('Delete',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
