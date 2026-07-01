import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/tv_device.dart';

/// Servicio para controlar TVs LG (webOS) via SSAP
/// LG usa SSDP para descubrimiento y WebSocket (puerto 3000) para control
class LgTvService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _ip;
  String? _clientId;
  int _pairingTimeout = 30;

  bool get isConnected => _isConnected;

  /// Conectar al TV LG
  Future<bool> connect(String ip) async {
    _ip = ip;
    
    try {
      final url = 'ws://$ip:3000';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      await _channel!.ready.timeout(const Duration(seconds: 5));
      
      _isConnected = true;
      
      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data);
            _handleMessage(json);
          } catch (_) {}
        },
        onDone: () => _isConnected = false,
        onError: (_) => _isConnected = false,
      );

      // Solicitar pairing
      _send('ssap://pairing/registerPairing', {
        'pairingType': 'PIN',
        'manifest': {
          'manifestVersion': 1,
          'appVersion': '1.0.0',
          'signed': {
            'appId': 'com.jox3.tvremote',
            'vendorId': 'com.jox3',
            'localizedAppNames': {
              '': 'TV Remote PRO',
            },
            'localizedVendorNames': {
              '': 'JOX3',
            },
            'permissions': [
              'CONTROL_AUDIO',
              'CONTROL_POWER',
              'CONTROL_TV_SCREEN',
              'READ_TV_CHANNEL_LIST',
              'WRITE_NOTIFICATION_TOAST',
              'CONTROL_TV_ABR_APP',
              'READ_INSTALLED_APPS',
              'LAUNCH_INSTALLED_APPS',
              'CONTROL_MOUSE_AND_KEYBOARD',
            ],
          },
        },
      });

      return true;
    } catch (e) {
      print('LG connect error: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Enviar comando
  Future<void> sendCommand(RemoteCommand command) async {
    if (!_isConnected) return;

    final uri = _commandToUri(command);
    if (uri == null) return;

    _send(uri, {});
  }

  /// Enviar texto (teclado)
  Future<void> sendText(String text) async {
    if (!_isConnected) return;

    _send('ssap://com.webos.service.ime/sendEnterKey', {});
    for (var char in text.split('')) {
      _send('ssap://com.webos.service.ime/insertText', {
        'text': char,
        'replace': 0,
      });
    }
  }

  /// Obtener apps instaladas
  Future<List<TvApp>> getApps() async {
    if (!_isConnected) return [];

    _send('ssap://com.webos.applicationManager/listApps', {});
    return [];
  }

  /// Lanzar app
  Future<void> launchApp(String appId) async {
    if (!_isConnected) return;

    _send('ssap://com.webos.applicationManager/launch', {
      'id': appId,
    });
  }

  /// Obtener info del TV
  Future<void> getDeviceInfo() async {
    if (!_isConnected) return;

    _send('ssap://com.webos.service.systemservice/getSystemInfo', {});
    _send('ssap://com.webos.service.systemservice/getPowerState', {});
  }

  /// Obtener volumen actual
  Future<void> getVolume() async {
    if (!_isConnected) return;

    _send('ssap://audio/getVolume', {});
  }

  /// Establecer volumen
  Future<void> setVolume(int volume) async {
    if (!_isConnected) return;

    _send('ssap://audio/setVolume', {'volume': volume});
  }

  /// Obtener canal actual
  Future<void> getCurrentChannel() async {
    if (!_isConnected) return;

    _send('ssap://tv/getCurrentChannel', {});
  }

  /// Obtener lista de canales
  Future<void> getChannelList() async {
    if (!_isConnected) return;

    _send('ssap://tv/getChannelList', {});
  }

  /// Cambiar canal
  Future<void> setChannel(String channelId) async {
    if (!_isConnected) return;

    _send('ssap://tv/openChannel', {'channelId': channelId});
  }

  /// Mostrar notificación en el TV
  Future<void> showNotification(String message) async {
    if (!_isConnected) return;

    _send('ssap://system.notifications/createToast', {
      'message': message,
    });
  }

  void _send(String uri, Map<String, dynamic> payload) {
    try {
      final msg = {
        'type': 'request',
        'id': 'req_${DateTime.now().millisecondsSinceEpoch}',
        'uri': uri,
        'payload': payload,
      };
      _channel?.sink.add(jsonEncode(msg));
    } catch (_) {}
  }

  void _handleMessage(Map<String, dynamic> data) {
    // Manejar respuestas del TV
    final id = data['id'];
    final payload = data['payload'];
    
    if (data['type'] == 'response') {
      // Respuesta exitosa
      print('LG Response [$id]: $payload');
    } else if (data['type'] == 'error') {
      // Error
      print('LG Error [$id]: ${data['error']}');
    }
  }

  String? _commandToUri(RemoteCommand cmd) {
    switch (cmd) {
      case RemoteCommand.power: return 'ssap://system/turnOff';
      case RemoteCommand.powerOff: return 'ssap://system/turnOff';
      case RemoteCommand.volumeUp: return 'ssap://audio/volumeUp';
      case RemoteCommand.volumeDown: return 'ssap://audio/volumeDown';
      case RemoteCommand.mute: return 'ssap://audio/setMute';
      case RemoteCommand.channelUp: return 'ssap://tv/channelUp';
      case RemoteCommand.channelDown: return 'ssap://tv/channelDown';
      case RemoteCommand.up: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.down: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.left: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.right: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.ok: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.enter: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.back: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.home: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.menu: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.exit: return 'ssap://com.webos.service.ime/sendEnterKey';
      case RemoteCommand.play: return 'ssap://media.controls/play';
      case RemoteCommand.pause: return 'ssap://media.controls/pause';
      case RemoteCommand.playPause: return 'ssap://media.controls/play';
      case RemoteCommand.stop: return 'ssap://media.controls/stop';
      case RemoteCommand.rewind: return 'ssap://media.controls/rewind';
      case RemoteCommand.fastForward: return 'ssap://media.controls/fastForward';
      case RemoteCommand.source: return 'ssap://tv/getExternalInputList';
      case RemoteCommand.settings: return 'ssap://com.webos.settingui/system/showQuickSettings';
      case RemoteCommand.info: return 'ssap://tv/getChannelProgramInfo';
      case RemoteCommand.guide: return 'ssap://tv/getChannelList';
      case RemoteCommand.red: return 'ssap://tv/sendRCKey';
      case RemoteCommand.green: return 'ssap://tv/sendRCKey';
      case RemoteCommand.yellow: return 'ssap://tv/sendRCKey';
      case RemoteCommand.blue: return 'ssap://tv/sendRCKey';
      case RemoteCommand.screenshot: return 'ssap://com.webos.service.capture/captureOneShot';
      default: return null;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
  }
}
