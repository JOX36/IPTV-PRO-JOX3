/// Modelo para un TV detectado/conectado
class TvDevice {
  final String id;
  final String name;
  final String brand; // Samsung, LG
  final String? ip;
  final String? mac;
  final String? model;
  final TvConnectionType connectionType;
  final bool isConnected;
  final Map<String, dynamic>? extra;

  const TvDevice({
    required this.id,
    required this.name,
    required this.brand,
    this.ip,
    this.mac,
    this.model,
    this.connectionType = TvConnectionType.wifi,
    this.isConnected = false,
    this.extra,
  });

  TvDevice copyWith({
    String? id,
    String? name,
    String? brand,
    String? ip,
    String? mac,
    String? model,
    TvConnectionType? connectionType,
    bool? isConnected,
    Map<String, dynamic>? extra,
  }) {
    return TvDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      ip: ip ?? this.ip,
      mac: mac ?? this.mac,
      model: model ?? this.model,
      connectionType: connectionType ?? this.connectionType,
      isConnected: isConnected ?? this.isConnected,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'ip': ip,
    'mac': mac,
    'model': model,
    'connectionType': connectionType.index,
    'isConnected': isConnected,
  };

  factory TvDevice.fromJson(Map<String, dynamic> json) => TvDevice(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    ip: json['ip'],
    mac: json['mac'],
    model: json['model'],
    connectionType: TvConnectionType.values[json['connectionType'] ?? 0],
    isConnected: json['isConnected'] ?? false,
  );
}

enum TvConnectionType { wifi, ir, bluetooth }

/// Comandos del control remoto
enum RemoteCommand {
  // Power
  power,
  powerOn,
  powerOff,
  
  // Navegación
  up,
  down,
  left,
  right,
  ok,
  enter,
  back,
  home,
  menu,
  exit,
  
  // Volumen
  volumeUp,
  volumeDown,
  mute,
  
  // Canales
  channelUp,
  channelDown,
  
  // Números
  num0, num1, num2, num3, num4,
  num5, num6, num7, num8, num9,
  
  // Controles de media
  play,
  pause,
  playPause,
  stop,
  rewind,
  fastForward,
  previous,
  next,
  
  // Input source
  source,
  tv,
  hdmi1, hdmi2, hdmi3, hdmi4,
  
  // Color buttons
  red, green, yellow, blue,
  
  // Smart features
  smartHub,
  apps,
  guide,
  info,
  settings,
  
  // Avanzado
  keyboard,
  voice,
  screenshot,
  channelList,
  aspectRatio,
  subtitle,
  teletext,
}

/// App del TV
class TvApp {
  final String id;
  final String name;
  final String? icon;
  final String? packageName;
  final bool isRunning;

  const TvApp({
    required this.id,
    required this.name,
    this.icon,
    this.packageName,
    this.isRunning = false,
  });
}
