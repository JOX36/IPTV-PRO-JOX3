/// Modelo para un canal/película/serie
class MediaItem {
  final String id;
  final String name;
  final String? logo;
  final String? group;
  final String? url;
  final String? streamId;
  final String? containerExtension;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? rating;
  final String? backdrop;
  final String? trailer;
  final Duration? duration;
  final MediaType type;
  final bool isFavorite;
  final int? season;
  final int? episode;
  final String? epgChannelId;

  const MediaItem({
    required this.id,
    required this.name,
    this.logo,
    this.group,
    this.url,
    this.streamId,
    this.containerExtension,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.rating,
    this.backdrop,
    this.trailer,
    this.duration,
    this.type = MediaType.live,
    this.isFavorite = false,
    this.season,
    this.episode,
    this.epgChannelId,
  });

  MediaItem copyWith({
    String? id,
    String? name,
    String? logo,
    String? group,
    String? url,
    String? streamId,
    String? containerExtension,
    String? plot,
    String? cast,
    String? director,
    String? genre,
    String? releaseDate,
    String? rating,
    String? backdrop,
    String? trailer,
    Duration? duration,
    MediaType? type,
    bool? isFavorite,
    int? season,
    int? episode,
    String? epgChannelId,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      group: group ?? this.group,
      url: url ?? this.url,
      streamId: streamId ?? this.streamId,
      containerExtension: containerExtension ?? this.containerExtension,
      plot: plot ?? this.plot,
      cast: cast ?? this.cast,
      director: director ?? this.director,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      backdrop: backdrop ?? this.backdrop,
      trailer: trailer ?? this.trailer,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      epgChannelId: epgChannelId ?? this.epgChannelId,
    );
  }

  /// Crear desde M3U EXTINF
  factory MediaItem.fromM3u(String name, String? logo, String? group, String url) {
    return MediaItem(
      id: url.hashCode.toString(),
      name: name.trim(),
      logo: logo,
      group: group,
      url: url,
      type: _detectType(group),
    );
  }

  /// Crear desde Xtream API
  factory MediaItem.fromXtreamLive(Map<String, dynamic> json, String serverUrl, String token) {
    final streamId = json['stream_id']?.toString() ?? '';
    final ext = json['container_extension'] ?? 'ts';
    return MediaItem(
      id: streamId,
      name: json['name'] ?? '',
      logo: json['stream_icon'],
      group: json['category_name'],
      url: '$serverUrl/live/$token/$streamId.$ext',
      streamId: streamId,
      containerExtension: ext,
      epgChannelId: json['epg_channel_id'],
      type: MediaType.live,
    );
  }

  factory MediaItem.fromXtreamVod(Map<String, dynamic> json, String serverUrl, String token) {
    final streamId = json['stream_id']?.toString() ?? '';
    final ext = json['container_extension'] ?? 'mp4';
    return MediaItem(
      id: streamId,
      name: json['name'] ?? '',
      logo: json['stream_icon'],
      group: json['category_name'],
      url: '$serverUrl/movie/$token/$streamId.$ext',
      streamId: streamId,
      containerExtension: ext,
      plot: json['plot'],
      cast: json['cast'],
      director: json['director'],
      genre: json['genre'],
      releaseDate: json['releaseDate'],
      rating: json['rating'],
      backdrop: json['backdrop_path'],
      duration: json['duration'] != null 
          ? Duration(minutes: int.tryParse(json['duration'].toString()) ?? 0) 
          : null,
      type: MediaType.movie,
    );
  }

  factory MediaItem.fromXtreamSeries(Map<String, dynamic> json, String serverUrl, String token) {
    final seriesId = json['series_id']?.toString() ?? '';
    return MediaItem(
      id: seriesId,
      name: json['name'] ?? '',
      logo: json['cover'],
      group: json['category_name'],
      url: '$serverUrl/series/$token/$seriesId',
      streamId: seriesId,
      plot: json['plot'],
      cast: json['cast'],
      director: json['director'],
      genre: json['genre'],
      releaseDate: json['releaseDate'],
      rating: json['rating'],
      backdrop: json['backdrop_path'],
      type: MediaType.series,
    );
  }

  static MediaType _detectType(String? group) {
    if (group == null) return MediaType.live;
    final g = group.toUpperCase();
    if (g.contains('MOVIE') || g.contains('PELÍCULA') || g.contains('CINE')) {
      return MediaType.movie;
    }
    if (g.contains('SERIE') || g.contains('SERIES')) {
      return MediaType.series;
    }
    return MediaType.live;
  }
}

enum MediaType { live, movie, series }

/// Modelo para una cuenta IPTV
class PlaylistConfig {
  final String id;
  final String name;
  final String serverUrl;
  final String? username;
  final String? password;
  final String? m3uUrl;
  final PlaylistType type;
  final DateTime createdAt;
  final bool isActive;

  const PlaylistConfig({
    required this.id,
    required this.name,
    required this.serverUrl,
    this.username,
    this.password,
    this.m3uUrl,
    this.type = PlaylistType.xtream,
    required this.createdAt,
    this.isActive = false,
  });

  String get baseUrl {
    if (username != null && password != null) {
      return '$serverUrl/player_api.php?username=$username&password=$password';
    }
    return serverUrl;
  }

  PlaylistConfig copyWith({
    String? id,
    String? name,
    String? serverUrl,
    String? username,
    String? password,
    String? m3uUrl,
    PlaylistType? type,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return PlaylistConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      m3uUrl: m3uUrl ?? this.m3uUrl,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'serverUrl': serverUrl,
    'username': username,
    'password': password,
    'm3uUrl': m3uUrl,
    'type': type.index,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  factory PlaylistConfig.fromJson(Map<String, dynamic> json) => PlaylistConfig(
    id: json['id'],
    name: json['name'],
    serverUrl: json['serverUrl'],
    username: json['username'],
    password: json['password'],
    m3uUrl: json['m3uUrl'],
    type: PlaylistType.values[json['type'] ?? 0],
    createdAt: DateTime.parse(json['createdAt']),
    isActive: json['isActive'] ?? false,
  );
}

enum PlaylistType { xtream, m3u }
