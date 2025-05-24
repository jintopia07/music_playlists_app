import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../models/playlist.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaylists extends AudioEvent {}

class LoadPlaylistSongs extends AudioEvent {
  final Playlist playlist;

  const LoadPlaylistSongs(this.playlist);

  @override
  List<Object> get props => [playlist];
}

class PlaySong extends AudioEvent {
  final Song song;

  const PlaySong(this.song);

  @override
  List<Object> get props => [song];
}

class PauseSong extends AudioEvent {}

class ResumeSong extends AudioEvent {}

class NextSong extends AudioEvent {}

class PreviousSong extends AudioEvent {}

class UpdatePosition extends AudioEvent {
  final Duration position;

  const UpdatePosition(this.position);

  @override
  List<Object> get props => [position];
}

class UpdateDuration extends AudioEvent {
  final Duration duration;

  const UpdateDuration(this.duration);

  @override
  List<Object> get props => [duration];
}

class SeekTo extends AudioEvent {
  final Duration position;

  const SeekTo(this.position);

  @override
  List<Object> get props => [position];
}

class ReturnToPlaylists extends AudioEvent {}

class UpdatePlayerState extends AudioEvent {
  final PlayerState playerState;

  const UpdatePlayerState(this.playerState);

  @override
  List<Object> get props => [playerState];
}
