import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

/// Cliente para la API de Xtream Codes
class XtreamClient {
  final String serverUrl;
  final String username;
  final String password;
  String? _authToken;
  Map<String, dynamic>? _serverInfo;

  XtreamClient({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  String get _baseUrl => serverUrl.endsWith('/') 
      ? serverUrl.substring(0, serverUrl.length - 1) 
      : serverUrl;

  String get _apiBase => '$_baseUrl/player_api.php?username=$username&password=$password';

  /// Autenticar y obtener info del servidor
  Future<Map<String, dynamic>?> authenticate() async {
    try {
      final response = await http.get(Uri.parse(_apiBase)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _serverInfo = data;
        _authToken = '$username/$password';
        return data;
      }
    } catch (e) {
      print('Auth error: $e');
    }
    return null;
  }

  /// Obtener categorías de Live TV
  Future<List<Map<String, dynamic>>> getLiveCategories() async {
    return _getCategories('get_live_categories');
  }

  /// Obtener categorías de VOD (películas)
  Future<List<Map<String, dynamic>>> getVodCategories() async {
    return _getCategories('get_vod_categories');
  }

  /// Obtener categorías de Series
  Future<List<Map<String, dynamic>>> getSeriesCategories() async {
    return _getCategories('get_series_categories');
  }

  Future<List<Map<String, dynamic>>> _getCategories(String action) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase&action=$action'),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print('Error getting categories ($action): $e');
    }
    return [];
  }

  /// Obtener streams de Live TV por categoría
  Future<List<MediaItem>> getLiveStreams({String? categoryId}) async {
    final url = categoryId != null 
        ? '$_apiBase&action=get_live_streams&category_id=$categoryId'
        : '$_apiBase&action=get_live_streams';
    return _getStreams(url, MediaType.live);
  }

  /// Obtener VOD (películas) por categoría
  Future<List<MediaItem>> getVodStreams({String? categoryId}) async {
    final url = categoryId != null 
        ? '$_apiBase&action=get_vod_streams&category_id=$categoryId'
        : '$_apiBase&action=get_vod_streams';
    return _getStreams(url, MediaType.movie);
  }

  /// Obtener series por categoría
  Future<List<MediaItem>> getSeries({String? categoryId}) async {
    final url = categoryId != null 
        ? '$_apiBase&action=get_series&category_id=$categoryId'
        : '$_apiBase&action=get_series';
    return _getStreams(url, MediaType.series);
  }

  Future<List<MediaItem>> _getStreams(String url, MediaType type) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map<MediaItem>((item) {
            switch (type) {
              case MediaType.live:
                return MediaItem.fromXtreamLive(item, _baseUrl, '$username/$password');
              case MediaType.movie:
                return MediaItem.fromXtreamVod(item, _baseUrl, '$username/$password');
              case MediaType.series:
                return MediaItem.fromXtreamSeries(item, _baseUrl, '$username/$password');
            }
          }).toList();
        }
      }
    } catch (e) {
      print('Error getting streams: $e');
    }
    return [];
  }

  /// Obtener info de cuenta (expiración, conexiones, etc.)
  Future<Map<String, dynamic>?> getAccountInfo() async {
    try {
      final response = await http.get(Uri.parse(_apiBase)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting account info: $e');
    }
    return null;
  }

  /// Obtener episodios de una serie
  Future<List<Map<String, dynamic>>> getSeriesEpisodes(String seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase&action=get_series_info&series_id=$seriesId'),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['episodes'] != null) {
          final episodes = <Map<String, dynamic>>[];
          for (final season in data['episodes'].values) {
            if (season is List) {
              episodes.addAll(season.cast<Map<String, dynamic>>());
            }
          }
          return episodes;
        }
      }
    } catch (e) {
      print('Error getting episodes: $e');
    }
    return [];
  }

  /// Buscar en todo el contenido
  Future<List<MediaItem>> search(String query) async {
    final results = <MediaItem>[];
    
    // Buscar en Live
    try {
      final liveResponse = await http.get(
        Uri.parse('$_apiBase&action=get_live_streams'),
      ).timeout(const Duration(seconds: 15));
      if (liveResponse.statusCode == 200) {
        final data = json.decode(liveResponse.body) as List;
        for (final item in data) {
          if ((item['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase())) {
            results.add(MediaItem.fromXtreamLive(item, _baseUrl, '$username/$password'));
          }
        }
      }
    } catch (_) {}

    // Buscar en VOD
    try {
      final vodResponse = await http.get(
        Uri.parse('$_apiBase&action=get_vod_streams'),
      ).timeout(const Duration(seconds: 15));
      if (vodResponse.statusCode == 200) {
        final data = json.decode(vodResponse.body) as List;
        for (final item in data) {
          if ((item['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase())) {
            results.add(MediaItem.fromXtreamVod(item, _baseUrl, '$username/$password'));
          }
        }
      }
    } catch (_) {}

    return results;
  }
}
