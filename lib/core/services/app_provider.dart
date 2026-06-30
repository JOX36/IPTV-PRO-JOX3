import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';
import '../services/xtream_client.dart';
import '../services/m3u_parser.dart';

class AppProvider extends ChangeNotifier {
  // Estado
  List<PlaylistConfig> _accounts = [];
  PlaylistConfig? _activeAccount;
  List<MediaItem> _liveChannels = [];
  List<MediaItem> _movies = [];
  List<MediaItem> _series = [];
  List<MediaItem> _favorites = [];
  List<MediaItem> _searchResults = [];
  List<Map<String, dynamic>> _liveCategories = [];
  List<Map<String, dynamic>> _vodCategories = [];
  List<Map<String, dynamic>> _seriesCategories = [];
  bool _isLoading = false;
  String? _error;
  String _currentCategoryFilter = '';
  XtreamClient? _client;

  // Getters
  List<PlaylistConfig> get accounts => _accounts;
  PlaylistConfig? get activeAccount => _activeAccount;
  List<MediaItem> get liveChannels => _liveChannels;
  List<MediaItem> get movies => _movies;
  List<MediaItem> get series => _series;
  List<MediaItem> get favorites => _favorites;
  List<MediaItem> get searchResults => _searchResults;
  List<Map<String, dynamic>> get liveCategories => _liveCategories;
  List<Map<String, dynamic>> get vodCategories => _vodCategories;
  List<Map<String, dynamic>> get seriesCategories => _seriesCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCategoryFilter => _currentCategoryFilter;
  XtreamClient? get client => _client;

  /// Cargar datos guardados
  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar cuentas
    final accountsJson = prefs.getStringList('accounts') ?? [];
    _accounts = accountsJson
        .map((json) => PlaylistConfig.fromJson(jsonDecode(json)))
        .toList();
    
    // Cargar favoritos
    final favsJson = prefs.getStringList('favorites') ?? [];
    _favorites = favsJson
        .map((json) => _mediaItemFromJson(jsonDecode(json)))
        .toList();
    
    // Cargar cuenta activa
    final activeId = prefs.getString('activeAccountId');
    if (activeId != null) {
      _activeAccount = _accounts.firstWhere(
        (a) => a.id == activeId,
        orElse: () => _accounts.isNotEmpty ? _accounts.first : throw Exception('No accounts'),
      );
    }
    
    notifyListeners();
  }

  /// Agregar cuenta Xtream
  Future<bool> addXtreamAccount(String name, String server, String user, String pass) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = XtreamClient(
        serverUrl: server,
        username: user,
        password: pass,
      );
      
      final authResult = await client.authenticate();
      if (authResult == null) {
        _error = 'No se pudo conectar al servidor. Verifica los datos.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final account = PlaylistConfig(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        serverUrl: server,
        username: user,
        password: pass,
        type: PlaylistType.xtream,
        createdAt: DateTime.now(),
        isActive: true,
      );

      _accounts.add(account);
      _activeAccount = account;
      _client = client;
      
      await _saveAccounts();
      await loadContent();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Agregar cuenta M3U
  Future<bool> addM3uAccount(String name, String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await M3uParser.fromUrl(url);
      if (items.isEmpty) {
        _error = 'No se encontraron canales en la lista M3U.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final account = PlaylistConfig(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        serverUrl: url,
        m3uUrl: url,
        type: PlaylistType.m3u,
        createdAt: DateTime.now(),
        isActive: true,
      );

      _accounts.add(account);
      _activeAccount = account;
      _liveChannels = items;
      
      await _saveAccounts();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cambiar cuenta activa
  Future<void> switchAccount(PlaylistConfig account) async {
    _activeAccount = account;
    _isLoading = true;
    notifyListeners();

    if (account.type == PlaylistType.xtream) {
      _client = XtreamClient(
        serverUrl: account.serverUrl,
        username: account.username!,
        password: account.password!,
      );
      await _client!.authenticate();
    }

    await loadContent();
    await _saveAccounts();
    
    _isLoading = false;
    notifyListeners();
  }

  /// Cargar contenido de la cuenta activa
  Future<void> loadContent() async {
    if (_activeAccount == null) return;

    if (_activeAccount!.type == PlaylistType.xtream && _client != null) {
      // Cargar en paralelo
      final results = await Future.wait([
        _client!.getLiveStreams(),
        _client!.getVodStreams(),
        _client!.getSeries(),
        _client!.getLiveCategories(),
        _client!.getVodCategories(),
        _client!.getSeriesCategories(),
      ]);
      
      _liveChannels = results[0] as List<MediaItem>;
      _movies = results[1] as List<MediaItem>;
      _series = results[2] as List<MediaItem>;
      _liveCategories = results[3] as List<Map<String, dynamic>>;
      _vodCategories = results[4] as List<Map<String, dynamic>>;
      _seriesCategories = results[5] as List<Map<String, dynamic>>;
    } else if (_activeAccount!.type == PlaylistType.m3u && _activeAccount!.m3uUrl != null) {
      _liveChannels = await M3uParser.fromUrl(_activeAccount!.m3uUrl!);
    }
    
    notifyListeners();
  }

  /// Buscar contenido
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    if (_client != null) {
      _searchResults = await _client!.search(query);
    } else {
      // Buscar localmente en M3U
      final q = query.toLowerCase();
      _searchResults = _liveChannels
          .where((item) => item.name.toLowerCase().contains(q))
          .toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Filtrar por categoría
  void filterByCategory(String category) {
    _currentCategoryFilter = category;
    notifyListeners();
  }

  /// Toggle favorito
  Future<void> toggleFavorite(MediaItem item) async {
    final index = _favorites.indexWhere((f) => f.id == item.id);
    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(item.copyWith(isFavorite: true));
    }
    await _saveFavorites();
    notifyListeners();
  }

  /// Verificar si es favorito
  bool isFavorite(String id) {
    return _favorites.any((f) => f.id == id);
  }

  /// Eliminar cuenta
  Future<void> removeAccount(PlaylistConfig account) async {
    _accounts.removeWhere((a) => a.id == account.id);
    if (_activeAccount?.id == account.id) {
      _activeAccount = _accounts.isNotEmpty ? _accounts.first : null;
      if (_activeAccount != null) {
        await switchAccount(_activeAccount!);
      }
    }
    await _saveAccounts();
    notifyListeners();
  }

  /// Guardar cuentas
  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = _accounts
        .map((account) => jsonEncode(account.toJson()))
        .toList();
    await prefs.setStringList('accounts', accountsJson);
    
    if (_activeAccount != null) {
      await prefs.setString('activeAccountId', _activeAccount!.id);
    }
  }

  /// Guardar favoritos
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favsJson = _favorites
        .map((item) => jsonEncode(_mediaItemToJson(item)))
        .toList();
    await prefs.setStringList('favorites', favsJson);
  }

  Map<String, dynamic> _mediaItemToJson(MediaItem item) => {
    'id': item.id,
    'name': item.name,
    'logo': item.logo,
    'group': item.group,
    'url': item.url,
    'type': item.type.index,
  };

  MediaItem _mediaItemFromJson(Map<String, dynamic> json) => MediaItem(
    id: json['id'],
    name: json['name'],
    logo: json['logo'],
    group: json['group'],
    url: json['url'],
    type: MediaType.values[json['type'] ?? 0],
  );
}
