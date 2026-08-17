import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/banner_ad_tile.dart';
import '../services/ad_service.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

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
              Expanded(
                child: Consumer<MusicProvider>(
                  builder: (context, musicProvider, child) {
                    final playlists = musicProvider.playlists;

                    if (playlists.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.playlist_add,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No playlists yet',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to create one',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    const int adInterval = 10;
                    int totalCount = playlists.length +
                        (playlists.length / adInterval).floor();

                    return ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 16 + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: totalCount,
                      itemBuilder: (context, index) {
                        if (index > 0 && (index + 1) % (adInterval + 1) == 0) {
                          return const BannerAdTile();
                        }

                        int playlistIndex = index - (index ~/ (adInterval + 1));
                        if (playlistIndex >= playlists.length) {
                          return const SizedBox.shrink();
                        }

                        final playlist = playlists[playlistIndex];
                        final songCount = playlist.songIds.length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: AppTheme.card3DDecoration,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: AppTheme.iconGradient,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: AppTheme.button3DShadow,
                              ),
                              child: const Icon(
                                Icons.playlist_play,
                                color: AppTheme.primaryTextColor,
                                size: 30,
                              ),
                            ),
                            title: Text(
                              playlist.name,
                              style: const TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '$songCount ${songCount == 1 ? 'song' : 'songs'}',
                              style: const TextStyle(
                                  color: AppTheme.secondaryTextColor),
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
                                if (value == 'delete') {
                                  _showDeleteDialog(
                                      context, musicProvider, playlist.id);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade900,
                                          Colors.red.shade700
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: AppTheme.elevated3DShadow,
                                      border: Border.all(
                                        color:
                                            Colors.red.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text('Delete Playlist',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Show ad on screen change (if ready), then navigate
                              AdService().showRewardedInterstitialAd(
                                onDismissed: () {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlaylistDetailScreen(
                                                playlist: playlist),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            onLongPress: () {
                              _showDeleteDialog(
                                  context, musicProvider, playlist.id);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.iconGradient,
          shape: BoxShape.circle,
          boxShadow: AppTheme.elevated3DShadow,
        ),
        child: FloatingActionButton(
          onPressed: () => _showCreatePlaylistDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: AppTheme.primaryTextColor),
        ),
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
          const Text(
            'Playlists',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Create Playlist',
            style: TextStyle(color: AppTheme.primaryTextColor)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.primaryTextColor),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: AppTheme.secondaryTextColor),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppTheme.primaryTextColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.secondaryTextColor)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                // Create playlist immediately — never gate on ads
                Provider.of<MusicProvider>(context, listen: false)
                    .createPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create',
                style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, MusicProvider provider, String playlistId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Playlist',
            style: TextStyle(color: AppTheme.primaryTextColor)),
        content: const Text('Are you sure you want to delete this playlist?',
            style: TextStyle(color: AppTheme.secondaryTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.secondaryTextColor)),
          ),
          TextButton(
            onPressed: () {
              // Delete immediately — never gate on ads
              provider.deletePlaylist(playlistId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
