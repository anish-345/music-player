import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_list_item.dart';
import '../widgets/mini_player.dart';
import '../services/permission_service.dart';
import '../constants/app_theme.dart';
import 'playlists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _sortBy = 'title'; // title, date

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Request notification permission for Android 13+
    await PermissionService.requestNotificationPermission();

    final hasPermission = await PermissionService.requestStoragePermission();

    if (hasPermission && mounted) {
      await Provider.of<MusicProvider>(context, listen: false).initialize();
    }
  }

  static const platform = MethodChannel('com.example.myapp/background');

  Future<void> _moveToBackground() async {
    try {
      await platform.invokeMethod('moveToBackground');
    } catch (e) {
      // If method channel fails, fallback to SystemNavigator
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Move app to background - music continues playing
        await _moveToBackground();
      },
      child: Scaffold(
        body: Container(
          color: AppTheme.backgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Consumer<MusicProvider>(
                  builder: (context, musicProvider, child) {
                    return _buildYoutubeToolsCard(context, musicProvider);
                  },
                ),
                if (_isSearching) _buildSearchBar(),
                Expanded(
                  child: Consumer<MusicProvider>(
                    builder: (context, musicProvider, child) {
                      if (musicProvider.isLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Loading music...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }

                      if (musicProvider.songs.isEmpty) {
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
                                _isSearching &&
                                        musicProvider.searchQuery.isNotEmpty
                                    ? 'No songs found'
                                    : 'No music files found',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: 80 + MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: musicProvider.songs.length,
                        itemBuilder: (context, index) {
                          return SongListItem(song: musicProvider.songs[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }

  Widget _buildYoutubeToolsCard(
      BuildContext context, MusicProvider musicProvider) {
    final hasStatus = musicProvider.youtubeConversionMessage != null ||
        musicProvider.latestYoutubeUrl != null;

    String subtitle = hasStatus
        ? musicProvider.youtubeConversionMessage ??
            'Ready to convert the latest shared YouTube link.'
        : 'Paste a YouTube link here, share one to this app, or open a YouTube URL with this app from Android.';

    if (musicProvider.isConvertingYoutube &&
        musicProvider.latestYoutubeUrl != null) {
      subtitle = '${subtitle}\n${musicProvider.latestYoutubeUrl}';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card3DDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  musicProvider.isConvertingYoutube
                      ? Icons.hourglass_top_rounded
                      : Icons.download_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'YouTube to MP3',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hasStatus)
                IconButton(
                  onPressed: musicProvider.isConvertingYoutube
                      ? null
                      : musicProvider.clearYoutubeStatus,
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: musicProvider.isConvertingYoutube
                  ? null
                  : () => _showYoutubeDownloadDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                musicProvider.isConvertingYoutube
                    ? Icons.downloading_rounded
                    : Icons.link_rounded,
              ),
              label: Text(
                musicProvider.isConvertingYoutube
                    ? 'Converting...'
                    : 'Paste YouTube Link',
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAppBar() {
    return Container(
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.iconGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.elevated3DShadow,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
          const SizedBox(width: 16),
          const Text(
            'Music',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: AppTheme.button3DShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.playlist_play,
                  color: AppTheme.primaryTextColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PlaylistsScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: AppTheme.button3DShadow,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.sort, color: AppTheme.primaryTextColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.transparent,
              elevation: 20,
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
                Provider.of<MusicProvider>(context, listen: false)
                    .sortSongs(value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'title',
                  child: Container(
                    decoration: AppTheme.popup3DDecoration,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _sortBy == 'title'
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: AppTheme.primaryTextColor,
                        ),
                        const SizedBox(width: 12),
                        const Text('Sort by Title',
                            style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'date',
                  child: Container(
                    decoration: AppTheme.popup3DDecoration,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _sortBy == 'date'
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: AppTheme.primaryTextColor,
                        ),
                        const SizedBox(width: 12),
                        const Text('Sort by Date',
                            style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: AppTheme.button3DShadow,
            ),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    Provider.of<MusicProvider>(context, listen: false)
                        .searchSongs('');
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.card3DDecoration,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search songs or artists...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          Provider.of<MusicProvider>(context, listen: false).searchSongs(value);
        },
      ),
    );
  }

  Future<void> _showYoutubeDownloadDialog(BuildContext context) async {
    final controller = TextEditingController();
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Convert YouTube to MP3',
          style: TextStyle(color: AppTheme.primaryTextColor),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'https://youtu.be/...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) async {
            Navigator.of(dialogContext).pop();
            await musicProvider.convertYoutubeToMp3(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await musicProvider.convertYoutubeToMp3(controller.text);
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }
}
