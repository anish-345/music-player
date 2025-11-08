import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../constants/app_theme.dart';

class SongListItem extends StatelessWidget {
  final Song song;

  const SongListItem({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: AppTheme.card3DDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.iconRadius),
            boxShadow: AppTheme.button3DShadow,
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
                return const Icon(Icons.music_note,
                    color: AppTheme.primaryTextColor, size: 30);
              },
            ),
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: const TextStyle(color: AppTheme.secondaryTextColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppTheme.button3DShadow,
            ),
            child: const Icon(Icons.more_vert,
                color: AppTheme.primaryTextColor, size: 20),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to play next')),
                );
                break;
              case 'add_queue':
                musicProvider.addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to queue')),
                );
                break;
              case 'delete':
                musicProvider.deleteSong(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Song removed')),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'play_next',
              child: Container(
                decoration: AppTheme.popup3DDecoration,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Row(
                  children: [
                    Icon(Icons.playlist_play, color: AppTheme.primaryTextColor),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: const Row(
                  children: [
                    Icon(Icons.queue_music, color: AppTheme.primaryTextColor),
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
              value: 'delete',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Delete',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () => musicProvider.playSong(song),
      ),
    );
  }
}
