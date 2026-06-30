import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

/// Parser para listas M3U/M3U8
class M3uParser {
  /// Parsear M3U desde URL
  static Future<List<MediaItem>> fromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode == 200) {
        return parse(response.body);
      }
    } catch (e) {
      print('Error fetching M3U: $e');
    }
    return [];
  }

  /// Parsear contenido M3U
  static List<MediaItem> parse(String content) {
    final items = <MediaItem>[];
    final lines = const LineSplitter().convert(content);
    
    String? currentName;
    String? currentLogo;
    String? currentGroup;
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.startsWith('#EXTINF:')) {
        // Parsear metadatos
        final info = _parseExtInf(line);
        currentName = info['name'];
        currentLogo = info['logo'];
        currentGroup = info['group'];
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        // Es una URL de stream
        if (currentName != null) {
          items.add(MediaItem.fromM3u(
            currentName,
            currentLogo,
            currentGroup,
            line,
          ));
        }
        currentName = null;
        currentLogo = null;
        currentGroup = null;
      }
    }
    
    return items;
  }

  /// Parsear línea #EXTINF
  static Map<String, String?> _parseExtInf(String line) {
    String? name;
    String? logo;
    String? group;
    
    // Extraer nombre (después de la última coma)
    final commaIndex = line.lastIndexOf(',');
    if (commaIndex != -1 && commaIndex < line.length - 1) {
      name = line.substring(commaIndex + 1).trim();
    }
    
    // Extraer tvg-logo
    final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
    if (logoMatch != null) {
      logo = logoMatch.group(1);
    }
    
    // Extraer group-title
    final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);
    if (groupMatch != null) {
      group = groupMatch.group(1);
    }
    
    // Extraer tvg-name
    final tvgNameMatch = RegExp(r'tvg-name="([^"]*)"').firstMatch(line);
    if (tvgNameMatch != null && (name == null || name.isEmpty)) {
      name = tvgNameMatch.group(1);
    }
    
    return {
      'name': name,
      'logo': logo,
      'group': group,
    };
  }

  /// Agrupar items por categoría
  static Map<String, List<MediaItem>> groupByCategory(List<MediaItem> items) {
    final grouped = <String, List<MediaItem>>{};
    for (final item in items) {
      final group = item.group ?? 'Sin categoría';
      grouped.putIfAbsent(group, () => []).add(item);
    }
    return grouped;
  }
}
