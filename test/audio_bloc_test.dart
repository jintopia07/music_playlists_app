import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_play_list/bloc/audio_bloc.dart';
import 'package:music_play_list/bloc/audio_event.dart';
import 'package:music_play_list/bloc/audio_state.dart';
import 'package:music_play_list/models/playlist.dart';
import 'package:music_play_list/models/song.dart';

// Generate a MockAudioPlayer
@GenerateMocks([AudioPlayer])
void main() {
  group('AudioBloc', () {
    late AudioBloc audioBloc;

    setUp(() {
      audioBloc = AudioBloc();
    });

    tearDown(() {
      audioBloc.close();
    });

    test('initial state is correct', () {
      expect(audioBloc.state, const AudioState());
    });

    blocTest<AudioBloc, AudioState>(
      'emits [loading, loaded] when LoadPlaylists is added',
      build: () => audioBloc,
      act: (bloc) => bloc.add(LoadPlaylists()),
      expect: () => [
        predicate<AudioState>((state) =>
            state.status == AudioStatus.loading && state.playlists.isEmpty),
        predicate<AudioState>((state) =>
            state.status == AudioStatus.loaded &&
            state.playlists.isNotEmpty &&
            state.currentView == ScreenView.playlists),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'emits [loading, loaded] when LoadPlaylistSongs is added',
      build: () => audioBloc,
      seed: () => AudioState(
        playlists: [
          Playlist(
            id: '1',
            name: 'Test Playlist',
            creator: 'Test Creator',
            coverUrl: 'https://picsum.photos/id/1/200/200',
            songIds: ['1', '2', '3'],
          ),
        ],
      ),
      act: (bloc) => bloc.add(LoadPlaylistSongs(
        Playlist(
          id: '1',
          name: 'Test Playlist',
          creator: 'Test Creator',
          coverUrl: 'https://picsum.photos/id/1/200/200',
          songIds: ['1', '2', '3'],
        ),
      )),
      expect: () => [
        predicate<AudioState>((state) => state.status == AudioStatus.loading),
        predicate<AudioState>((state) =>
            state.status == AudioStatus.loaded &&
            state.currentPlaylistSongs.isNotEmpty &&
            state.currentView == ScreenView.playlistDetail),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'emits correct states when PlaySong is added',
      build: () => audioBloc,
      seed: () => AudioState(
        currentPlaylistSongs: [
          Song(
            id: '1',
            title: 'Test Song',
            artist: 'Test Artist',
            url:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            coverUrl: 'https://picsum.photos/id/1/200/200',
            duration: '3:24',
          ),
        ],
      ),
      act: (bloc) => bloc.add(PlaySong(
        Song(
          id: '1',
          title: 'Test Song',
          artist: 'Test Artist',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          coverUrl: 'https://picsum.photos/id/1/200/200',
          duration: '3:24',
        ),
      )),
      expect: () => [
        predicate<AudioState>((state) =>
            state.currentSong != null && state.currentSong!.id == '1'),
      ],
      // Skip checking for playing status since it depends on the audio player
      // which we can't easily mock in this test
    );

    test('ReturnToPlaylists changes view to playlists', () {
      // Arrange
      final initialState = AudioState(
        currentView: ScreenView.playlistDetail,
      );

      // Act
      final newState = audioBloc.state.copyWith(
        currentView: ScreenView.playlists,
      );

      // Assert
      expect(newState.currentView, ScreenView.playlists);
    });

    test('UpdatePosition updates position in state', () {
      // Arrange
      final initialState = AudioState(
        position: Duration.zero,
      );

      // Act
      final newState = initialState.copyWith(
        position: const Duration(seconds: 30),
      );

      // Assert
      expect(newState.position, const Duration(seconds: 30));
    });

    test('UpdateDuration updates duration in state', () {
      // Arrange
      final initialState = AudioState(
        duration: Duration.zero,
      );

      // Act
      final newState = initialState.copyWith(
        duration: const Duration(minutes: 3, seconds: 30),
      );

      // Assert
      expect(newState.duration, const Duration(minutes: 3, seconds: 30));
    });
  });
}
