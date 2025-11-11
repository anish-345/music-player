import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../constants/app_theme.dart';

class PlaylistSongItem extends StatelessWidget {
  final Song song;
  final String playlistId;

  const PlaylistSongItem({
    super.key,
    required this.song,
    required this.playlistId,
  });

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
          onTap: () => musicProvider.playSong(song),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.iconRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.1),
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
                      case 'remove':
                        musicProvider.removeSongFromPlaylist(
                            playlistId, song.id);
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
                      value: 'remove',
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade900, Colors.red.shade700],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.elevated3DShadow,
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: const Row(
                          children: [
                            Icon(Icons.remove_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Remove from Playlist',
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
}
