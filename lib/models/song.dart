class Song {
  final String id;
  final String title;
  final String artist;
  final String? albumArt;
  final String path;
  final int duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    required this.path,
    required this.duration,
  });
}
