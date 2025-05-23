import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/song_list_item.dart';
import 'player_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state.currentPlaylist == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(state.currentPlaylist!.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              _buildPlaylistHeader(context, state),
              Expanded(
                child: ListView.builder(
                  itemCount: state.currentPlaylistSongs.length,
                  itemBuilder: (context, index) {
                    final song = state.currentPlaylistSongs[index];
                    final isPlaying = state.currentSong?.id == song.id &&
                        state.status == AudioStatus.playing;

                    return SongListItem(
                      song: song,
                      isPlaying: isPlaying,
                      onTap: () {
                        // Play the song
                        context.read<AudioBloc>().add(PlaySong(song));

                        // Navigate to player screen immediately
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlayerScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaylistHeader(BuildContext context, AudioState state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.black,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              state.currentPlaylist!.coverUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.currentPlaylist!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'By ${state.currentPlaylist!.creator}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (state.currentPlaylistSongs.isNotEmpty) {
                          // Play the first song in the playlist
                          context.read<AudioBloc>().add(
                                PlaySong(state.currentPlaylistSongs.first),
                              );

                          // Navigate to player screen immediately
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlayerScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Play'),
                    ),
                    const SizedBox(width: 8.0),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Shuffle',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
