import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/playlist_item.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Playlist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          if (state.status == AudioStatus.initial) {
            context.read<AudioBloc>().add(LoadPlaylists());
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AudioStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.playlists.isEmpty) {
            return const Center(child: Text('No playlists available'));
          }

          return ListView.builder(
            itemCount: state.playlists.length,
            itemBuilder: (context, index) {
              final playlist = state.playlists[index];

              return PlaylistItem(
                playlist: playlist,
                onTap: () {
                  context.read<AudioBloc>().add(LoadPlaylistSongs(playlist));
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          if (state.currentSong == null) {
            return const SizedBox.shrink();
          }

          return Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      state.currentSong!.coverUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.currentSong!.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        state.currentSong!.artist,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    state.status == AudioStatus.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 32,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (state.status == AudioStatus.playing) {
                      context.read<AudioBloc>().add(PauseSong());
                    } else {
                      context.read<AudioBloc>().add(ResumeSong());
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
