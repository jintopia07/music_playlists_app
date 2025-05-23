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
      // Uncomment this to use real API data
      // final response = await http.get(Uri.parse('$_apiBaseUrl/playlists'));
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   final playlists = data.map((json) => Playlist(
      //     id: json['id'],
      //     name: json['name'],
      //     creator: json['creator'],
      //     coverUrl: json['coverUrl'],
      //     songIds: List<String>.from(json['songIds']),
      //   )).toList();
      //   emit(state.copyWith(
      //     playlists: playlists,
      //     status: AudioStatus.loaded,
      //     currentView: ScreenView.playlists,
      //   ));
      // } else {
      //   throw Exception('Failed to load playlists');
      // }

      // Using mock data for now
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
      // Uncomment this to use real API data
      // final response = await http.get(
      //   Uri.parse('$_apiBaseUrl/playlists/${event.playlist.id}/songs')
      // );
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   final songs = data.map((json) => Song(
      //     id: json['id'],
      //     title: json['title'],
      //     artist: json['artist'],
      //     url: json['url'],
      //     coverUrl: json['coverUrl'],
      //     duration: json['duration'],
      //   )).toList();
      //
      //   emit(state.copyWith(
      //     currentPlaylistSongs: songs,
      //     currentPlaylist: event.playlist,
      //     status: AudioStatus.loaded,
      //     currentView: ScreenView.playlistDetail,
      //   ));
      // } else {
      //   throw Exception('Failed to load songs');
      // }

      // Using mock data for now
      final songs = [
        Song(
          id: '1',
          title: 'Ashamed',
          artist: 'Omar Apollo',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          coverUrl: 'https://picsum.photos/id/11/200/200',
          duration: '3:24',
        ),
        Song(
          id: '2',
          title: 'Kickback',
          artist: 'Omar Apollo',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          coverUrl: 'https://picsum.photos/id/12/200/200',
          duration: '2:51',
        ),
        Song(
          id: '3',
          title: 'So Good',
          artist: 'Omar Apollo',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
          coverUrl: 'https://picsum.photos/id/13/200/200',
          duration: '4:26',
        ),
        Song(
          id: '4',
          title: 'Frío',
          artist: 'Omar Apollo',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
          coverUrl: 'https://picsum.photos/id/14/200/200',
          duration: '2:05',
        ),
        Song(
          id: '5',
          title: 'Brakelights',
          artist: 'Omar Apollo',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
          coverUrl: 'https://picsum.photos/id/15/200/200',
          duration: '2:48',
        ),
        Song(
          id: '6',
          title: 'Trouble',
          artist: 'Omar Apollo',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
          coverUrl: 'https://picsum.photos/id/16/200/200',
          duration: '3:23',
        ),
      ];

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

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
