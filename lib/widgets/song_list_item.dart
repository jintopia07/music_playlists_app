import 'package:flutter/material.dart';
import '../models/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongListItem({
    Key? key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.coverUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 48,
              height: 48,
              color: Colors.grey[800],
              child: const Icon(
                Icons.music_note,
                size: 24,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
        ),
        key: ValueKey('title-${song.id}'),
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(color: Colors.grey),
        key: ValueKey('artist-${song.id}'),
      ),
      trailing: isPlaying
          ? const Icon(Icons.equalizer, color: Colors.green)
          : const Icon(Icons.play_arrow, color: Colors.white),
      onTap: onTap,
    );
  }
}
