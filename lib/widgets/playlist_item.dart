import 'package:flutter/material.dart';
import '../models/playlist.dart';

class PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistItem({
    Key? key,
    required this.playlist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image.network(
          playlist.coverUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[800],
              child: const Icon(
                Icons.music_note,
                size: 30,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        playlist.creator,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.play_circle_outline,
          size: 40,
          color: Colors.grey,
        ),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }
}
