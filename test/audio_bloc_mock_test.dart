import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_play_list/bloc/audio_bloc.dart';
import 'package:music_play_list/bloc/audio_event.dart';
import 'package:music_play_list/bloc/audio_state.dart';
import 'package:music_play_list/models/song.dart';
import 'dart:async';

// Create a mock class for AudioPlayer
class MockAudioPlayer extends Mock implements AudioPlayer {
  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 3, seconds: 30);

  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Duration get position => _position;
  Duration? get duration => _duration;
  bool get playing => _isPlaying;

  @override
  Future<Duration?> setUrl(String url,
      {Map<String, String>? headers,
      Duration? initialPosition,
      bool preload = true,
      dynamic tag}) async {
    _duration = const Duration(minutes: 3, seconds: 30);
    _durationController.add(_duration);
    return Future.value(_duration);
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    _playerStateController.add(PlayerState(true, ProcessingState.ready));
    return Future.value();
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _playerStateController.add(PlayerState(false, ProcessingState.ready));
    return Future.value();
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    if (position != null) {
      _position = position;
      _positionController.add(_position);
    }
    return Future.value();
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _position = Duration.zero;
    _playerStateController.add(PlayerState(false, ProcessingState.ready));
    _positionController.add(_position);
    return Future.value();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
    return Future.value();
  }
}

// Create a testable version of AudioBloc
class TestableAudioBloc extends Bloc<AudioEvent, AudioState> {
  final MockAudioPlayer audioPlayer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  TestableAudioBloc(this.audioPlayer) : super(const AudioState()) {
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
    on<UpdatePlayerState>(_onUpdatePlayerState);

    // Listen to position changes
    _positionSubscription = audioPlayer.positionStream.listen(
      (position) => add(UpdatePosition(position)),
    );

    // Listen to duration changes
    _durationSubscription = audioPlayer.durationStream.listen(
      (duration) {
        if (duration != null) {
          add(UpdateDuration(duration));
        }
      },
    );

    // Listen to player state changes
    _playerStateSubscription = audioPlayer.playerStateStream.listen(
      (playerState) => add(UpdatePlayerState(playerState)),
    );
  }

  void _onLoadPlaylists(LoadPlaylists event, Emitter<AudioState> emit) {}
  void _onLoadPlaylistSongs(
      LoadPlaylistSongs event, Emitter<AudioState> emit) {}

  void _onUpdatePosition(UpdatePosition event, Emitter<AudioState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<AudioState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<AudioState> emit) async {
    await audioPlayer.seek(event.position);
    emit(state.copyWith(position: event.position));
  }

  void _onUpdatePlayerState(
      UpdatePlayerState event, Emitter<AudioState> emit) {}
  void _onReturnToPlaylists(
      ReturnToPlaylists event, Emitter<AudioState> emit) {}
  void _onPreviousSong(PreviousSong event, Emitter<AudioState> emit) {}
  void _onNextSong(NextSong event, Emitter<AudioState> emit) {}
  void _onResumeSong(ResumeSong event, Emitter<AudioState> emit) {}
  void _onPauseSong(PauseSong event, Emitter<AudioState> emit) {}

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
      await audioPlayer.stop();
      await audioPlayer.setUrl(event.song.url);

      // Get the duration immediately if possible
      final duration = await audioPlayer.durationFuture;
      if (duration != null) {
        emit(state.copyWith(duration: duration));
      }

      await audioPlayer.play();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    audioPlayer.dispose();
    return super.close();
  }
}

void main() {
  // Initialize Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioBloc with mocked AudioPlayer', () {
    late MockAudioPlayer mockAudioPlayer;
    late TestableAudioBloc audioBloc;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();
      audioBloc = TestableAudioBloc(mockAudioPlayer);
    });

    tearDown(() async {
      await audioBloc.close();
    });

    testWidgets('seek updates position correctly', (WidgetTester tester) async {
      // Arrange
      final testSong = Song(
        id: '1',
        title: 'Test Song',
        artist: 'Test Artist',
        url: 'https://example.com/song.mp3',
        coverUrl: 'https://example.com/cover.jpg',
        duration: '3:30',
      );

      // Play song first
      audioBloc.add(PlaySong(testSong));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Act - Seek to position
      final seekPosition = const Duration(minutes: 1, seconds: 30);
      audioBloc.add(SeekTo(seekPosition));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Assert
      expect(audioBloc.state.position, seekPosition);
    });
  });
}
