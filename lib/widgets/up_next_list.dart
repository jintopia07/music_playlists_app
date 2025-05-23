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

    // Get all songs including the current one
    final allSongs = songs;

    return Container(
      color: const Color(0xFF1E1B2E), // Dark navy background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar at the top
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF2A2A40),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'UP NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'LYRICS',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'RELATED',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // "Playing from" section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Playing from',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '2020 - New!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.playlist_add,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Song list
          Expanded(
            child: ListView.builder(
              itemCount: allSongs.length,
              itemBuilder: (context, index) {
                final song = allSongs[index];
                final isCurrentSong = song.id == currentSong.id;

                return _buildSongItem(context, song, isCurrentSong,
                    index == currentIndex // Current song
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(
      BuildContext context, Song song, bool isCurrentSong, bool isPlaying) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.coverUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          key: ValueKey('img-${song.id}'),
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 40,
              height: 40,
              color: Colors.grey[800],
              child: const Icon(
                Icons.music_note,
                size: 20,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isCurrentSong ? Colors.green : Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              '${song.artist} • ${song.duration}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.grey,
          size: 20,
        ),
        onPressed: () {},
      ),
      onTap: () {
        if (!isCurrentSong) {
          // Play the selected song
          context.read<AudioBloc>().add(PlaySong(song));
        }
      },
    );
  }
}
