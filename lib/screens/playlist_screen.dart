import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/song_list_item.dart';
import '../models/playlist.dart';
import 'playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioBloc, AudioState>(
      listenWhen: (previous, current) =>
          previous.currentView != current.currentView,
      listener: (context, state) {
        if (state.currentView == ScreenView.playlistDetail) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlaylistDetailScreen(),
            ),
          ).then((_) {
            // When returning from the detail screen, make sure we're in playlists view
            if (state.currentView != ScreenView.playlists) {
              context.read<AudioBloc>().add(ReturnToPlaylists());
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Library',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  _buildFilterChip('Playlists', true),
                  _buildFilterChip('Songs', false),
                  _buildFilterChip('Albums', false),
                  _buildFilterChip('Artists', false),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_drop_down),
                  Spacer(),
                  Icon(Icons.grid_view),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AudioBloc, AudioState>(
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
                      return _buildPlaylistItem(context, playlist);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Samples',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Library',
            ),
          ],
          currentIndex: 3,
          onTap: (index) {},
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(BuildContext context, Playlist playlist) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          playlist.coverUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              color: Colors.grey[800],
              child: const Icon(
                Icons.music_note,
                size: 28,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Playlist • ${playlist.creator} • ${playlist.songIds.length} tracks',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {},
      ),
      onTap: () {
        context.read<AudioBloc>().add(LoadPlaylistSongs(playlist));
      },
    );
  }
}
