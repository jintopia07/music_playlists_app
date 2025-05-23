import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/song.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';

class UpNextList extends StatelessWidget {
  final Song currentSong;
  final List<Song> songs;

  const UpNextList({
    Key? key,
    required this.currentSong,
    required this.songs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the index of the current song
    final currentIndex = songs.indexWhere((song) => song.id == currentSong.id);

    // If the song isn't in the list or it's the last song, show a message
    if (currentIndex == -1 || currentIndex >= songs.length - 1) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No more songs in the playlist',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Get the upcoming songs (all songs after the current one)
    final upcomingSongs = songs.sublist(currentIndex + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                'Playing from',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.playlist_add,
                    color: Colors.white, size: 20),
                label: const Text('Save',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: upcomingSongs.length,
            itemBuilder: (context, index) {
              final song = upcomingSongs[index];
              return _buildSongItem(context, song);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongItem(BuildContext context, Song song) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.coverUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          key: ValueKey('img-${song.id}'),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.duration}',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.menu, color: Colors.grey),
        onPressed: () {},
        iconSize: 20,
      ),
      onTap: () {
        // Play the selected song - this will trigger the loading state
        context.read<AudioBloc>().add(PlaySong(song));

        // No need to navigate since we're already on the player screen
      },
    );
  }
}
