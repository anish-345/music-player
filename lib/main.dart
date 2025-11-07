
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => MusicProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class Song {
  final String title;
  final String artist;
  final String path;
  final String? album;

  Song({
    required this.title,
    required this.artist,
    required this.path,
    this.album,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}

class Playlist {
  final String name;
  final List<Song> songs;

  Playlist({required this.name, required this.songs});
}

class MusicProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Song> _allSongs = [];
  List<Song> _nowPlayingPlaylist = [];
  final List<Playlist> _userPlaylists = [];
  int? _currentSongIndex;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  List<Song> get allSongs => _allSongs;
  List<Song> get nowPlayingPlaylist => _nowPlayingPlaylist;
  List<Playlist> get userPlaylists => _userPlaylists;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;

  MusicProvider() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        playNext();
      }
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      notifyListeners();
    });
  }

  Future<void> pickFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          final song = Song(
            title: file.name.split('.').first,
            artist: 'Unknown Artist',
            path: file.path!,
          );
          if (!_allSongs.contains(song)) {
            _allSongs.add(song);
          }
        }
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.files.length} songs added!')),
      );
      notifyListeners();
    }
  }

  void play(int index, {List<Song>? playlist}) {
    _nowPlayingPlaylist = List.from(playlist ?? _allSongs);
    _currentSongIndex = index;
    _audioPlayer.play(DeviceFileSource(_nowPlayingPlaylist[index].path));
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    notifyListeners();
  }

  void playNext() {
    if (_currentSongIndex != null && _nowPlayingPlaylist.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex! + 1) % _nowPlayingPlaylist.length;
      play(_currentSongIndex!);
    }
  }

  void playPrevious() {
    if (_currentSongIndex != null && _nowPlayingPlaylist.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex! - 1 + _nowPlayingPlaylist.length) %
          _nowPlayingPlaylist.length;
      play(_currentSongIndex!);
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void createPlaylist(String name, BuildContext context) {
    _userPlaylists.add(Playlist(name: name, songs: []));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playlist "$name" created!')),
    );
    notifyListeners();
  }

  void addSongToPlaylist(Playlist playlist, Song song, BuildContext context) {
    playlist.songs.add(song);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${song.title} to ${playlist.name}')),
    );
    notifyListeners();
  }

  void addToQueue(Song song, BuildContext context) {
    if (_currentSongIndex != null) {
      _nowPlayingPlaylist.insert(_currentSongIndex! + 1, song);
    } else {
      _nowPlayingPlaylist.add(song);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${song.title} added to queue')),
    );
    notifyListeners();
  }

  Future<void> deleteSong(Song song, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text(
            'Are you sure you want to permanently delete ${song.title} from your device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final file = File(song.path);
        if (await file.exists()) {
          await file.delete();
        }
        if (!context.mounted) return;
        _allSongs.remove(song);
        _nowPlayingPlaylist.remove(song);
        for (var playlist in _userPlaylists) {
          playlist.songs.remove(song);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${song.title} has been deleted.')),
        );
        notifyListeners();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting song: $e')),
        );
      }
    }
  }

  Map<String, List<Song>> get songsByFolder {
    final Map<String, List<Song>> folderMap = {};
    for (var song in _allSongs) {
      final directory = File(song.path).parent.path;
      if (folderMap.containsKey(directory)) {
        folderMap[directory]!.add(song);
      } else {
        folderMap[directory] = [song];
      }
    }
    return folderMap;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = TextTheme(
      displayLarge:
          GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Qtonz Music Player',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qtonz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => musicProvider.pickFiles(context),
            tooltip: 'Add Music',
          ),
          IconButton(
            icon: Icon(context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 20),
                  SizedBox(width: 8),
                  Text('Songs'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, size: 20),
                  SizedBox(width: 8),
                  Text('Folders'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_play, size: 20),
                  SizedBox(width: 8),
                  Text('Playlists'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                SongListView(),
                FolderView(),
                PlaylistView(),
              ],
            ),
          ),
          if (musicProvider.currentSongIndex != null)
            const PlayerBanner(),
        ],
      ),
    );
  }
}

class SongListView extends StatelessWidget {
  const SongListView({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return musicProvider.allSongs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_off, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No music found.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add songs.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: musicProvider.allSongs.length,
            itemBuilder: (context, index) {
              final song = musicProvider.allSongs[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () => musicProvider.play(index, playlist: musicProvider.allSongs),
                leading: const Icon(Icons.music_note),
                selected: musicProvider.currentSongIndex != null &&
                    musicProvider.nowPlayingPlaylist.isNotEmpty &&
                    musicProvider.nowPlayingPlaylist[musicProvider.currentSongIndex!] == song,
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case 'play':
                        musicProvider.play(index, playlist: musicProvider.allSongs);
                        break;
                      case 'queue':
                        musicProvider.addToQueue(song, context);
                        break;
                      case 'playlist':
                        _showAddToPlaylistDialog(context, song);
                        break;
                      case 'delete':
                        musicProvider.deleteSong(song, context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'play', child: Text('Play Now')),
                    const PopupMenuItem(value: 'queue', child: Text('Add to Queue')),
                    const PopupMenuItem(value: 'playlist', child: Text('Add to Playlist')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final musicProvider = context.read<MusicProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: musicProvider.userPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = musicProvider.userPlaylists[index];
                return ListTile(
                  title: Text(playlist.name),
                  onTap: () {
                    musicProvider.addSongToPlaylist(playlist, song, context);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class FolderView extends StatelessWidget {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final songsByFolder = musicProvider.songsByFolder;
    final folders = songsByFolder.keys.toList();

    return folders.isEmpty
        ? Center(
            child: Text(
              'No folders found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        : ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final songs = songsByFolder[folder]!;
              return ExpansionTile(
                title: Text(folder.split('/').last),
                leading: const Icon(Icons.folder),
                children: songs
                    .map((song) => ListTile(
                          title: Text(song.title),
                          onTap: () {
                            final songIndex = songs.indexOf(song);
                            musicProvider.play(songIndex, playlist: songs);
                          },
                        ))
                    .toList(),
              );
            },
          );
  }
}

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return ListView.builder(
      itemCount: musicProvider.userPlaylists.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create Playlist'),
            onTap: () => _showCreatePlaylistDialog(context),
          );
        }
        final playlist = musicProvider.userPlaylists[index - 1];
        return ListTile(
          title: Text(playlist.name),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailView(playlist: playlist),
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Playlist Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<MusicProvider>().createPlaylist(controller.text, context);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class PlaylistDetailView extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailView({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: playlist.songs.isEmpty
          ? const Center(child: Text('This playlist is empty.'))
          : ListView.builder(
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                return ListTile(
                  title: Text(song.title),
                  onTap: () => musicProvider.play(index, playlist: playlist.songs),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSongDialog(context, playlist),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSongDialog(BuildContext context, Playlist playlist) {
    final musicProvider = context.read<MusicProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Song to Playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: musicProvider.allSongs.length,
              itemBuilder: (context, index) {
                final song = musicProvider.allSongs[index];
                return ListTile(
                  title: Text(song.title),
                  onTap: () {
                    musicProvider.addSongToPlaylist(playlist, song, context);
                    Navigator.pop(dialogContext);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class PlayerBanner extends StatelessWidget {
  const PlayerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    if (musicProvider.currentSongIndex == null || musicProvider.nowPlayingPlaylist.isEmpty) {
      return const SizedBox.shrink();
    }
    final song = musicProvider.nowPlayingPlaylist[musicProvider.currentSongIndex!];

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artist,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () => musicProvider.playPrevious(),
              ),
              IconButton(
                iconSize: 40.0,
                icon: Icon(
                  musicProvider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                ),
                onPressed: () {
                  if (musicProvider.isPlaying) {
                    musicProvider.pause();
                  } else {
                    musicProvider.resume();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => musicProvider.playNext(),
              ),
            ],
          ),
          Slider(
            value: musicProvider.position.inSeconds.toDouble(),
            max: musicProvider.duration.inSeconds.toDouble().clamp(0.0, double.infinity),
            onChanged: (value) {
              musicProvider.seek(Duration(seconds: value.toInt()));
            },
          ),
        ],
      ),
    );
  }
}
