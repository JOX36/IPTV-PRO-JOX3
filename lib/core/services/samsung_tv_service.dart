import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/tv_device.dart';

/// Servicio para controlar TVs Samsung via WebSocket
/// Samsung usa un API WebSocket en el puerto 8002 (SSL) o 8001
class SamsungTvService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _ip;
  String? _token;
  final StreamController<RemoteCommand> _commandController = 
      StreamController<RemoteCommand>.broadcast();

  bool get isConnected => _isConnected;
  Stream<RemoteCommand> get commandStream => _commandController.stream;

  /// Conectar al TV Samsung
  Future<bool> connect(String ip, {String? token}) async {
    _ip = ip;
    _token = token;
    
    try {
      // Samsung TV WebSocket API
      final url = 'wss://$ip:8002/api/v2/channels/samsung.remote.control'
          '?name=${base64Encode(utf8.encode('TVRemotePRO'))}'
          '${token != null ? "&token=$token" : ""}';
      
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Esperar conexión
      await _channel!.ready.timeout(const Duration(seconds: 5));
      
      _isConnected = true;
      
      // Escuchar respuestas
      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data);
            _handleMessage(json);
          } catch (_) {}
        },
        onDone: () {
          _isConnected = false;
        },
        onError: (_) {
          _isConnected = false;
        },
      );

      // Solicitar token de autenticación
      _send({
        'method': 'ms.channel.connect',
        'params': {
          'clientIp': '192.168.1.100',
          'macAddress': '00:00:00:00:00:00',
          'deviceName': base64Encode(utf8.encode('TVRemotePRO')),
        },
      });

      return true;
    } catch (e) {
      print('Samsung connect error: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Enviar comando al TV
  Future<void> sendCommand(RemoteCommand command) async {
    if (!_isConnected) return;

    final key = _commandToKey(command);
    if (key == null) return;

    _send({
      'method': 'ms.remote.control',
      'params': {
        'Cmd': 'Click',
        'DataOfCmd': key,
        'Option': 'false',
        'TypeOfRemote': 'SendRemoteKey',
      },
    });
  }

  /// Enviar texto (para teclado)
  Future<void> sendText(String text) async {
    if (!_isConnected) return;

    _send({
      'method': 'ms.remote.control',
      'params': {
        'Cmd': text,
        'DataOfCmd': text,
        'Option': 'true',
        'TypeOfRemote': 'SendInputString',
      },
    });
  }

  /// Obtener apps instaladas
  Future<List<TvApp>> getApps() async {
    if (!_isConnected) return [];

    _send({
      'method': 'ms.channel.emit',
      'params': {
        'event': 'ed.installedApp.get',
        'to': 'host',
      },
    });

    // Las apps llegan por el stream de mensajes
    return [];
  }

  /// Lanzar app por package name
  Future<void> launchApp(String packageName) async {
    if (!_isConnected) return;

    _send({
      'method': 'ms.channel.emit',
      'params': {
        'event': 'ed.apps.launch',
        'to': 'host',
        'data': {
          'appId': packageName,
          'action_type': 'DEEP_LINK',
        },
      },
    });
  }

  /// Obtener info del TV
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    if (!_isConnected) return null;

    _send({
      'method': 'ms.channel.emit',
      'params': {
        'event': 'ed.device.info.get',
        'to': 'host',
      },
    });

    return null;
  }

  void _send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void _handleMessage(Map<String, dynamic> data) {
    final event = data['event'];
    if (event == 'ms.channel.connect') {
      _token = data['data']?['token'];
    }
  }

  String? _commandToKey(RemoteCommand cmd) {
    switch (cmd) {
      case RemoteCommand.power: return 'KEY_POWER';
      case RemoteCommand.powerOn: return 'KEY_POWERON';
      case RemoteCommand.powerOff: return 'KEY_POWEROFF';
      case RemoteCommand.up: return 'KEY_UP';
      case RemoteCommand.down: return 'KEY_DOWN';
      case RemoteCommand.left: return 'KEY_LEFT';
      case RemoteCommand.right: return 'KEY_RIGHT';
      case RemoteCommand.ok: return 'KEY_ENTER';
      case RemoteCommand.enter: return 'KEY_ENTER';
      case RemoteCommand.back: return 'KEY_RETURN';
      case RemoteCommand.home: return 'KEY_HOME';
      case RemoteCommand.menu: return 'KEY_MENU';
      case RemoteCommand.exit: return 'KEY_EXIT';
      case RemoteCommand.volumeUp: return 'KEY_VOLUP';
      case RemoteCommand.volumeDown: return 'KEY_VOLDOWN';
      case RemoteCommand.mute: return 'KEY_MUTE';
      case RemoteCommand.channelUp: return 'KEY_CHUP';
      case RemoteCommand.channelDown: return 'KEY_CHDOWN';
      case RemoteCommand.num0: return 'KEY_0';
      case RemoteCommand.num1: return 'KEY_1';
      case RemoteCommand.num2: return 'KEY_2';
      case RemoteCommand.num3: return 'KEY_3';
      case RemoteCommand.num4: return 'KEY_4';
      case RemoteCommand.num5: return 'KEY_5';
      case RemoteCommand.num6: return 'KEY_6';
      case RemoteCommand.num7: return 'KEY_7';
      case RemoteCommand.num8: return 'KEY_8';
      case RemoteCommand.num9: return 'KEY_9';
      case RemoteCommand.play: return 'KEY_PLAY';
      case RemoteCommand.pause: return 'KEY_PAUSE';
      case RemoteCommand.playPause: return 'KEY_PLAY_PAUSE';
      case RemoteCommand.stop: return 'KEY_STOP';
      case RemoteCommand.rewind: return 'KEY_REWIND';
      case RemoteCommand.fastForward: return 'KEY_FF';
      case RemoteCommand.previous: return 'KEY_PREV';
      case RemoteCommand.next: return 'KEY_NEXT';
      case RemoteCommand.source: return 'KEY_SOURCE';
      case RemoteCommand.tv: return 'KEY_TV';
      case RemoteCommand.hdmi1: return 'KEY_HDMI1';
      case RemoteCommand.hdmi2: return 'KEY_HDMI2';
      case RemoteCommand.hdmi3: return 'KEY_HDMI3';
      case RemoteCommand.hdmi4: return 'KEY_HDMI4';
      case RemoteCommand.red: return 'KEY_RED';
      case RemoteCommand.green: return 'KEY_GREEN';
      case RemoteCommand.yellow: return 'KEY_YELLOW';
      case RemoteCommand.blue: return 'KEY_BLUE';
      case RemoteCommand.smartHub: return 'KEY_SMART_HUB';
      case RemoteCommand.apps: return 'KEY_APPS';
      case RemoteCommand.guide: return 'KEY_GUIDE';
      case RemoteCommand.info: return 'KEY_INFO';
      case RemoteCommand.settings: return 'KEY_SETTINGS';
      case RemoteCommand.channelList: return 'KEY_CH_LIST';
      case RemoteCommand.aspectRatio: return 'KEY_ASPECT';
      case RemoteCommand.subtitle: return 'KEY_SUB_TITLE';
      case RemoteCommand.teletext: return 'KEY_TTX_MIX';
      default: return null;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _commandController.close();
  }
}
