import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/playlist.dart';
import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  // You can replace this with your actual API base URL
  final String _apiBaseUrl = 'https://api.example.com/music';

  AudioBloc() : super(const AudioState()) {
    on<LoadPlaylists>(_onLoadPlaylists);
    on<LoadPlaylistSongs>(_onLoadPlaylistSongs);
    on<PlaySong>(_onPlaySong);
    on<PauseSong>(_onPauseSong);
    on<ResumeSong>(_onResumeSong);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdateDuration>(_onUpdateDuration);
    on<SeekTo>(_onSeekTo);
    on<ReturnToPlaylists>(_onReturnToPlaylists);

    // Listen to position changes
    _positionSubscription = _audioPlayer.positionStream.listen(
      (position) => add(UpdatePosition(position)),
    );

    // Listen to duration changes
    _durationSubscription = _audioPlayer.durationStream.listen(
      (duration) {
        if (duration != null) {
          add(UpdateDuration(duration));
        }
      },
    );
  }

  void _onUpdatePosition(UpdatePosition event, Emitter<AudioState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<AudioState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<AudioState> emit) async {
    await _audioPlayer.seek(event.position);
    emit(state.copyWith(position: event.position));
  }

  Future<void> _onLoadPlaylists(
      LoadPlaylists event, Emitter<AudioState> emit) async {
    emit(state.copyWith(status: AudioStatus.loading));
    try {
      final playlists = [
        Playlist(
          id: '1',
          name: 'Tech House Vibes',
          creator: 'A&K',
          coverUrl: 'https://picsum.photos/id/1/200/200',
          songIds: ['1', '2', '3'],
        ),
        Playlist(
          id: '2',
          name: 'Summer Hits',
          creator: 'Hits',
          coverUrl: 'https://picsum.photos/id/2/200/200',
          songIds: ['4', '5', '6'],
        ),
        Playlist(
          id: '3',
          name: 'Techno 2021',
          creator: 'the 2021 group',
          coverUrl: 'https://picsum.photos/id/3/200/200',
          songIds: ['7', '8', '9'],
        ),
        Playlist(
          id: '4',
          name: 'Vibe with me',
          creator: 'housy',
          coverUrl: 'https://picsum.photos/id/4/200/200',
          songIds: ['10', '11', '12'],
        ),
        Playlist(
          id: '5',
          name: 'Listen&Chill',
          creator: 'Hipster',
          coverUrl: 'https://picsum.photos/id/5/200/200',
          songIds: ['13', '14', '15'],
        ),
      ];
      emit(state.copyWith(
        playlists: playlists,
        status: AudioStatus.loaded,
        currentView: ScreenView.playlists,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AudioStatus.loaded));
    }
  }

  Future<void> _onLoadPlaylistSongs(
      LoadPlaylistSongs event, Emitter<AudioState> emit) async {
    emit(state.copyWith(status: AudioStatus.loading));
    try {
      // Different songs for each playlist
      final Map<String, List<Song>> playlistSongs = {
        '1': [
          Song(
            id: '1',
            title: 'Ashamed',
            artist: 'Omar Apollo',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            coverUrl: 'https://picsum.photos/id/11/200/200',
            duration: '3:24',
          ),
          Song(
            id: '2',
            title: 'Kickback',
            artist: 'Omar Apollo',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
            coverUrl: 'https://picsum.photos/id/12/200/200',
            duration: '2:51',
          ),
          Song(
            id: '3',
            title: 'So Good',
            artist: 'Omar Apollo',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
            coverUrl: 'https://picsum.photos/id/13/200/200',
            duration: '4:26',
          ),
        ],
        '2': [
          Song(
            id: '4',
            title: 'Summer Nights',
            artist: 'John Legend',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
            coverUrl: 'https://picsum.photos/id/14/200/200',
            duration: '3:15',
          ),
          Song(
            id: '5',
            title: 'Sunshine',
            artist: 'Dua Lipa',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
            coverUrl: 'https://picsum.photos/id/15/200/200',
            duration: '2:48',
          ),
          Song(
            id: '6',
            title: 'Beach Day',
            artist: 'The Weeknd',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
            coverUrl: 'https://picsum.photos/id/16/200/200',
            duration: '3:23',
          ),
        ],
        '3': [
          Song(
            id: '7',
            title: 'Techno Beat',
            artist: 'DJ Alesso',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
            coverUrl: 'https://picsum.photos/id/17/200/200',
            duration: '4:12',
          ),
          Song(
            id: '8',
            title: 'Electronic Pulse',
            artist: 'Avicii',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
            coverUrl: 'https://picsum.photos/id/18/200/200',
            duration: '3:45',
          ),
          Song(
            id: '9',
            title: 'Digital Dreams',
            artist: 'Deadmau5',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
            coverUrl: 'https://picsum.photos/id/19/200/200',
            duration: '5:20',
          ),
        ],
        '4': [
          Song(
            id: '10',
            title: 'Chill Vibes',
            artist: 'Khalid',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
            coverUrl: 'https://picsum.photos/id/20/200/200',
            duration: '3:33',
          ),
          Song(
            id: '11',
            title: 'Relax Mode',
            artist: 'Frank Ocean',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            coverUrl: 'https://picsum.photos/id/21/200/200',
            duration: '4:17',
          ),
          Song(
            id: '12',
            title: 'Mellow Mood',
            artist: 'Daniel Caesar',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
            coverUrl: 'https://picsum.photos/id/22/200/200',
            duration: '3:05',
          ),
        ],
        '5': [
          Song(
            id: '13',
            title: 'Indie Rock',
            artist: 'Arctic Monkeys',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
            coverUrl: 'https://picsum.photos/id/23/200/200',
            duration: '4:02',
          ),
          Song(
            id: '14',
            title: 'Alternative Beats',
            artist: 'Tame Impala',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
            coverUrl: 'https://picsum.photos/id/24/200/200',
            duration: '3:56',
          ),
          Song(
            id: '15',
            title: 'Hipster Vibes',
            artist: 'Mac DeMarco',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
            coverUrl: 'https://picsum.photos/id/25/200/200',
            duration: '3:22',
          ),
        ],
      };

      // Get songs for the selected playlist
      final songs = playlistSongs[event.playlist.id] ?? [];

      emit(state.copyWith(
        currentPlaylistSongs: songs,
        currentPlaylist: event.playlist,
        status: AudioStatus.loaded,
        currentView: ScreenView.playlistDetail,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), status: AudioStatus.loaded));
    }
  }

  Future<void> _onPlaySong(PlaySong event, Emitter<AudioState> emit) async {
    try {
      // Immediately update the state with the new song
      emit(state.copyWith(
        currentSong: event.song,
        status: AudioStatus.playing,
        currentView: ScreenView.player,
        // Reset position for the new song
        position: Duration.zero,
      ));

      // Set up and play the audio in the background
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(event.song.url);

      // Get the duration immediately if possible
      final duration = await _audioPlayer.durationFuture;
      if (duration != null) {
        emit(state.copyWith(duration: duration));
      }

      await _audioPlayer.play();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onPauseSong(PauseSong event, Emitter<AudioState> emit) async {
    if (state.status == AudioStatus.playing) {
      await _audioPlayer.pause();
      emit(state.copyWith(status: AudioStatus.paused));
    }
  }

  Future<void> _onResumeSong(ResumeSong event, Emitter<AudioState> emit) async {
    if (state.status == AudioStatus.paused) {
      await _audioPlayer.play();
      emit(state.copyWith(status: AudioStatus.playing));
    }
  }

  Future<void> _onNextSong(NextSong event, Emitter<AudioState> emit) async {
    if (state.currentSong != null && state.currentPlaylistSongs.isNotEmpty) {
      final currentIndex = state.currentPlaylistSongs
          .indexWhere((song) => song.id == state.currentSong!.id);

      if (currentIndex < state.currentPlaylistSongs.length - 1) {
        final nextSong = state.currentPlaylistSongs[currentIndex + 1];
        add(PlaySong(nextSong));
      }
    }
  }

  Future<void> _onPreviousSong(
      PreviousSong event, Emitter<AudioState> emit) async {
    if (state.currentSong != null && state.currentPlaylistSongs.isNotEmpty) {
      final currentIndex = state.currentPlaylistSongs
          .indexWhere((song) => song.id == state.currentSong!.id);

      if (currentIndex > 0) {
        final previousSong = state.currentPlaylistSongs[currentIndex - 1];
        add(PlaySong(previousSong));
      }
    }
  }

  void _onReturnToPlaylists(ReturnToPlaylists event, Emitter<AudioState> emit) {
    emit(state.copyWith(
      currentView: ScreenView.playlists,
      // Keep the current song playing if there is one
    ));
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
