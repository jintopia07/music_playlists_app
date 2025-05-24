import 'package:equatable/equatable.dart';
import '../models/song.dart';
import '../models/playlist.dart';

enum AudioStatus { initial, loading, loaded, playing, paused, completed }

enum ScreenView { playlists, playlistDetail, player }

class AudioState extends Equatable {
  final List<Playlist> playlists;
  final List<Song> currentPlaylistSongs;
  final Playlist? currentPlaylist;
  final Song? currentSong;
  final AudioStatus status;
  final ScreenView currentView;
  final String? error;
  final Duration position;
  final Duration duration;

  const AudioState({
    this.playlists = const [],
    this.currentPlaylistSongs = const [],
    this.currentPlaylist,
    this.currentSong,
    this.status = AudioStatus.initial,
    this.currentView = ScreenView.playlists,
    this.error,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioState copyWith({
    List<Playlist>? playlists,
    List<Song>? currentPlaylistSongs,
    Playlist? currentPlaylist,
    Song? currentSong,
    AudioStatus? status,
    ScreenView? currentView,
    String? error,
    Duration? position,
    Duration? duration,
  }) {
    return AudioState(
      playlists: playlists ?? this.playlists,
      currentPlaylistSongs: currentPlaylistSongs ?? this.currentPlaylistSongs,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      currentSong: currentSong ?? this.currentSong,
      status: status ?? this.status,
      currentView: currentView ?? this.currentView,
      error: error ?? this.error,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
        playlists,
        currentPlaylistSongs,
        currentPlaylist,
        currentSong,
        status,
        currentView,
        error,
        position,
        duration,
      ];
}
