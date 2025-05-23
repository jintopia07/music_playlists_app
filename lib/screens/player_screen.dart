import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/up_next_list.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  String _selectedTab = 'UP NEXT';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioBloc, AudioState>(
      listenWhen: (previous, current) =>
          previous.currentSong?.id != current.currentSong?.id ||
          previous.status != current.status ||
          previous.position != current.position ||
          previous.duration != current.duration,
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        if (state.currentSong == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
                child: Text('No song selected',
                    style: TextStyle(color: Colors.white))),
          );
        }

        // Calculate slider value
        double sliderValue = 0.0;
        if (state.duration.inMilliseconds > 0) {
          sliderValue =
              state.position.inMilliseconds / state.duration.inMilliseconds;
          // Clamp value between 0 and 1
          sliderValue = sliderValue.clamp(0.0, 1.0);
        }

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => Navigator.pop(context),
            ),
            title: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Song',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Video',
                      style: TextStyle(color: Colors.grey),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.cast),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          body: _buildPlayerView(context, state, sliderValue),
        );
      },
    );
  }

  Widget _buildPlayerView(
      BuildContext context, AudioState state, double sliderValue) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                state.currentSong!.coverUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                key: ValueKey(state.currentSong!.id),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.currentSong!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                key: ValueKey('title-${state.currentSong!.id}'),
              ),
              const SizedBox(height: 4),
              Text(
                state.currentSong!.artist,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                key: ValueKey('artist-${state.currentSong!.id}'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_outlined,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      Text('26K', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.thumb_down_outlined,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.comment_outlined,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      Text('484', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.playlist_add, color: Colors.white),
                    label: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('16K',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: sliderValue,
                  onChanged: (value) {
                    if (state.duration.inMilliseconds > 0) {
                      final position = Duration(
                        milliseconds:
                            (value * state.duration.inMilliseconds).round(),
                      );
                      context.read<AudioBloc>().add(SeekTo(position));
                    }
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[800],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(state.position),
                        style: TextStyle(color: Colors.grey),
                        key: ValueKey('position-${state.position.inSeconds}')),
                    Text(_formatDuration(state.duration),
                        style: TextStyle(color: Colors.grey),
                        key: ValueKey('duration-${state.duration.inSeconds}')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle,
                        color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        color: Colors.white, size: 36),
                    onPressed: () {
                      context.read<AudioBloc>().add(PreviousSong());
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        state.status == AudioStatus.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.black,
                        size: 36,
                      ),
                      onPressed: () {
                        if (state.status == AudioStatus.playing) {
                          context.read<AudioBloc>().add(PauseSong());
                        } else {
                          context.read<AudioBloc>().add(ResumeSong());
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        color: Colors.white, size: 36),
                    onPressed: () {
                      context.read<AudioBloc>().add(NextSong());
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.repeat, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton('UP NEXT'),
                  _buildTabButton('LYRICS'),
                  _buildTabButton('RELATED'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Show the appropriate content based on the selected tab
        Expanded(
          flex: 3,
          child: _selectedTab == 'UP NEXT'
              ? UpNextList(
                  key: ValueKey('upnext-${state.currentSong!.id}'),
                  currentSong: state.currentSong!,
                  songs: state.currentPlaylistSongs,
                )
              : _selectedTab == 'LYRICS'
                  ? const Center(
                      child: Text(
                        'Lyrics not available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Related content not available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String tabName) {
    final isSelected = _selectedTab == tabName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabName;
        });
      },
      child: Column(
        children: [
          Text(
            tabName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 60,
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
