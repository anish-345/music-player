import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../screens/player_screen.dart';
import '../constants/app_theme.dart';
import '../services/ad_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final currentSong = musicProvider.currentSong;

        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            // Show Rewarded Interstitial Ad before opening player
            AdService().showRewardedInterstitialAd(
              onDismissed: () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlayerScreen()),
                  );
                }
              },
            );
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              musicProvider.playPrevious();
            } else if (details.primaryVelocity! < 0) {
              musicProvider.playNext();
            }
          },
          child: Container(
            height: 70,
            margin: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.elevated3DShadow,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentSong.title,
                        style: const TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentSong.artist,
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.button3DShadow,
                  ),
                  child: IconButton(
                    icon: Icon(
                      musicProvider.audioPlayer.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: AppTheme.primaryTextColor,
                    ),
                    onPressed: () => musicProvider.playPause(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.button3DShadow,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: AppTheme.primaryTextColor,
                    ),
                    onPressed: () => musicProvider.playNext(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
