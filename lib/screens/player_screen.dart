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
  bool _showUpNext = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioBloc, AudioState>(
      listenWhen: (previous, current) =>
          previous.currentSong?.id != current.currentSong?.id ||
          previous.status != current.status ||
          previous.position != current.position ||
          previous.duration != current.duration,
      listener: (context, state) {
        // Force rebuild when status changes
        if (mounted) {
          setState(() {});
        }
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
            backgroundColor: const Color(0xFF1E1B2E),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                Text(
                  state.currentSong!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.currentSong!.artist,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.cast_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  state.status == AudioStatus.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (state.status == AudioStatus.playing) {
                    context.read<AudioBloc>().add(PauseSong());
                  } else {
                    context.read<AudioBloc>().add(ResumeSong());
                  }
                  // Force rebuild
                  setState(() {});
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Main player content
              Column(
                children: [
                  // Album art
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              state.currentSong!.coverUrl,
                              fit: BoxFit.cover,
                              key: ValueKey(state.currentSong!.id),
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Progress bar and time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Progress slider
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.grey[800],
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: sliderValue,
                            onChanged: (value) {
                              if (state.duration.inMilliseconds > 0) {
                                final position = Duration(
                                  milliseconds:
                                      (value * state.duration.inMilliseconds)
                                          .round(),
                                );
                                context.read<AudioBloc>().add(SeekTo(position));
                              }
                            },
                          ),
                        ),

                        // Time indicators
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(state.position),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(state.duration),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Player controls
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle,
                              color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white, size: 32),
                          onPressed: () {
                            context.read<AudioBloc>().add(PreviousSong());
                          },
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              state.status == AudioStatus.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.black,
                              size: 32,
                            ),
                            onPressed: () {
                              if (state.status == AudioStatus.playing) {
                                context.read<AudioBloc>().add(PauseSong());
                              } else {
                                context.read<AudioBloc>().add(ResumeSong());
                              }
                              // Force rebuild
                              setState(() {});
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white, size: 32),
                          onPressed: () {
                            context.read<AudioBloc>().add(NextSong());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.repeat,
                              color: Colors.white, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Up Next button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showUpNext = !_showUpNext;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A40),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.queue_music,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Up Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Up Next overlay
              if (_showUpNext)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showUpNext = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        children: [
                          // Close button
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showUpNext = false;
                                  });
                                },
                              ),
                            ),
                          ),

                          // Up Next list
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1B2E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: UpNextList(
                                  key: ValueKey(
                                      'upnext-${state.currentSong!.id}'),
                                  currentSong: state.currentSong!,
                                  songs: state.currentPlaylistSongs,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
