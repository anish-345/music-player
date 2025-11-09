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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All songs are already in this playlist'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _MultiSelectSongsDialog(
        availableSongs: availableSongs,
        playlistId: playlist.id,
        musicProvider: musicProvider,
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

class _MultiSelectSongsDialog extends StatefulWidget {
  final List availableSongs;
  final String playlistId;
  final MusicProvider musicProvider;

  const _MultiSelectSongsDialog({
    required this.availableSongs,
    required this.playlistId,
    required this.musicProvider,
  });

  @override
  State<_MultiSelectSongsDialog> createState() =>
      _MultiSelectSongsDialogState();
}

class _MultiSelectSongsDialogState extends State<_MultiSelectSongsDialog> {
  final Set<String> _selectedSongIds = {};
  bool _selectAll = false;

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedSongIds.addAll(widget.availableSongs.map((s) => s.id));
      } else {
        _selectedSongIds.clear();
      }
    });
  }

  void _toggleSong(String songId) {
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
        _selectAll = false;
      } else {
        _selectedSongIds.add(songId);
        if (_selectedSongIds.length == widget.availableSongs.length) {
          _selectAll = true;
        }
      }
    });
  }

  void _addSelectedSongs() {
    for (final songId in _selectedSongIds) {
      widget.musicProvider.addSongToPlaylist(widget.playlistId, songId);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedSongIds.length} songs added to playlist'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          const Expanded(
            child: Text('Add Songs to Playlist',
                style: TextStyle(color: AppTheme.primaryTextColor)),
          ),
          TextButton.icon(
            onPressed: _toggleSelectAll,
            icon: Icon(
              _selectAll ? Icons.check_box : Icons.check_box_outline_blank,
              color: AppTheme.primaryTextColor,
              size: 20,
            ),
            label: const Text(
              'All',
              style: TextStyle(color: AppTheme.primaryTextColor),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            if (_selectedSongIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.iconGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedSongIds.length} song${_selectedSongIds.length == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableSongs.length,
                itemBuilder: (context, index) {
                  final song = widget.availableSongs[index];
                  final isSelected = _selectedSongIds.contains(song.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: AppTheme.primaryTextColor, width: 2)
                          : null,
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
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleSong(song.id),
                        activeColor: AppTheme.primaryTextColor,
                        checkColor: AppTheme.surfaceColor,
                      ),
                      onTap: () => _toggleSong(song.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: AppTheme.secondaryTextColor)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.iconGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: _selectedSongIds.isEmpty ? null : _addSelectedSongs,
            child: Text(
              'Add (${_selectedSongIds.length})',
              style: TextStyle(
                color: _selectedSongIds.isEmpty
                    ? AppTheme.secondaryTextColor
                    : AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
