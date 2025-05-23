class Playlist {
  final String id;
  final String name;
  final String creator;
  final String coverUrl;
  final List<String> songIds;

  Playlist({
    required this.id,
    required this.name,
    required this.creator,
    required this.coverUrl,
    required this.songIds,
  });
}