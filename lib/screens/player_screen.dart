import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/music_provider.dart';
import 'queue_screen.dart';
import '../constants/app_theme.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Consumer<MusicProvider>(
            builder: (context, musicProvider, child) {
              final currentSong = musicProvider.currentSong;

              if (currentSong == null) {
                return const Center(
                  child: Text(
                    'No song playing',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return Column(
                children: [
                  _buildAppBar(context),
                  const Spacer(),
                  _buildAlbumArt(),
                  const SizedBox(height: 40),
                  _buildSongInfo(currentSong),
                  const Spacer(),
                  _buildActionButtons(context, currentSong),
                  const SizedBox(height: 20),
                  _buildProgressBar(musicProvider),
                  const SizedBox(height: 30),
                  _buildControls(musicProvider),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
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
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Now Playing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Hero(
      tag: 'album_art',
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.15),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkNavy.withValues(alpha: 0.6),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/muico.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.music_note,
                size: 120,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(dynamic song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Text(
            song.title,
            style: const TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            song.artist,
            style: const TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.share,
          onPressed: () async {
            try {
              // Share the actual audio file only
              final file = File(song.path);
              if (await file.exists()) {
                await Share.shareXFiles(
                  [XFile(song.path)],
                  sharePositionOrigin: Rect.fromLTWH(0, 0, 10, 10),
                );
              }
            } catch (e) {
              // Silently fail if sharing fails
            }
          },
        ),
        const SizedBox(width: 40),
        _buildActionButton(
          icon: Icons.queue_music,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QueueScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.button3DShadow,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.primaryTextColor),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildProgressBar(MusicProvider musicProvider) {
    final position = musicProvider.audioPlayer.position;
    final duration = musicProvider.audioPlayer.duration ?? Duration.zero;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkNavy.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: AppTheme.primaryTextColor,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                thumbColor: AppTheme.primaryTextColor,
                overlayColor: Colors.white.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble() > 0
                    ? duration.inSeconds.toDouble()
                    : 1.0,
                onChanged: (value) {
                  musicProvider.seekTo(Duration(seconds: value.toInt()));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(MusicProvider musicProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.shuffle,
            size: 28,
            onPressed: () => musicProvider.toggleShuffle(),
            isActive: musicProvider.isShuffled,
          ),
          _buildControlButton(
            icon: Icons.skip_previous,
            size: 42,
            onPressed: () => musicProvider.playPrevious(),
          ),
          _buildControlButton(
            icon: musicProvider.audioPlayer.playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
            size: 72,
            onPressed: () => musicProvider.playPause(),
            gradient: true,
          ),
          _buildControlButton(
            icon: Icons.skip_next,
            size: 42,
            onPressed: () => musicProvider.playNext(),
          ),
          _buildRepeatButton(musicProvider),
        ],
      ),
    );
  }

  Widget _buildRepeatButton(MusicProvider musicProvider) {
    IconData icon;
    bool isActive = musicProvider.loopMode != LoopMode.off;

    switch (musicProvider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        break;
    }

    return _buildControlButton(
      icon: icon,
      size: 28,
      onPressed: () => musicProvider.toggleRepeat(),
      isActive: isActive,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    bool gradient = false,
    bool isActive = false,
  }) {
    return Container(
      decoration: gradient
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.iconGradient,
              boxShadow: AppTheme.elevated3DShadow,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            )
          : BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              boxShadow: AppTheme.button3DShadow,
              border: Border.all(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
      child: IconButton(
        icon: Icon(icon,
            color: isActive
                ? AppTheme.primaryTextColor
                : AppTheme.secondaryTextColor),
        iconSize: size,
        onPressed: onPressed,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
