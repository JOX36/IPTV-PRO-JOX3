import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tv_device.dart';
import 'samsung_tv_service.dart';
import 'lg_tv_service.dart';
import 'ir_service.dart';

class TvProvider extends ChangeNotifier {
  final SamsungTvService _samsungService = SamsungTvService();
  final LgTvService _lgService = LgTvService();
  final IrService _irService = IrService();

  List<TvDevice> _savedDevices = [];
  TvDevice? _activeDevice;
  bool _isLoading = false;
  String? _error;
  bool _hasIrBlaster = false;
  int _currentVolume = 30;
  String _currentChannel = '';
  bool _isMuted = false;
  String _lastCommand = '';
  DateTime _lastCommandTime = DateTime.now();

  // Getters
  List<TvDevice> get savedDevices => _savedDevices;
  TvDevice? get activeDevice => _activeDevice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasIrBlaster => _hasIrBlaster;
  bool get isConnected => _activeDevice?.isConnected ?? false;
  int get currentVolume => _currentVolume;
  String get currentChannel => _currentChannel;
  bool get isMuted => _isMuted;
  String get lastCommand => _lastCommand;
  DateTime get lastCommandTime => _lastCommandTime;
  String get activeBrand => _activeDevice?.brand ?? 'samsung';

  Future<void> init() async {
    _hasIrBlaster = await _irService.hasIrBlaster();
    await _loadSavedDevices();
    notifyListeners();
  }

  /// Guardar dispositivo
  Future<void> saveDevice(TvDevice device) async {
    _savedDevices.add(device);
    await _saveDevices();
    notifyListeners();
  }

  /// Conectar a un TV por WiFi
  Future<bool> connectWifi(TvDevice device) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool success = false;

    if (device.brand == 'Samsung') {
      success = await _samsungService.connect(device.ip!);
    } else if (device.brand == 'LG') {
      success = await _lgService.connect(device.ip!);
    }

    if (success) {
      _activeDevice = device.copyWith(isConnected: true);
      // Actualizar en la lista guardada
      final idx = _savedDevices.indexWhere((d) => d.id == device.id);
      if (idx != -1) {
        _savedDevices[idx] = _activeDevice!;
      }
      await _saveDevices();
    } else {
      _error = 'No se pudo conectar al TV. Verifica la IP y que esté en la misma red.';
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Conectar por IR (sin necesidad de WiFi)
  void connectIr(TvDevice device) {
    _activeDevice = device.copyWith(
      isConnected: true,
      connectionType: TvConnectionType.ir,
    );
    notifyListeners();
  }

  /// Enviar comando
  Future<void> sendCommand(RemoteCommand command) async {
    _lastCommand = command.name;
    _lastCommandTime = DateTime.now();
    notifyListeners();

    if (_activeDevice == null) return;

    if (_activeDevice!.connectionType == TvConnectionType.ir) {
      await _irService.sendCommand(
        command,
        brand: _activeDevice!.brand.toLowerCase(),
      );
    } else if (_activeDevice!.brand == 'Samsung') {
      await _samsungService.sendCommand(command);
    } else if (_activeDevice!.brand == 'LG') {
      await _lgService.sendCommand(command);
    }

    // Actualizar estado local
    _updateLocalState(command);
  }

  /// Enviar texto (teclado)
  Future<void> sendText(String text) async {
    if (_activeDevice == null) return;

    if (_activeDevice!.brand == 'Samsung') {
      await _samsungService.sendText(text);
    } else if (_activeDevice!.brand == 'LG') {
      await _lgService.sendText(text);
    }
  }

  /// Lanzar app
  Future<void> launchApp(String appId) async {
    if (_activeDevice == null) return;

    if (_activeDevice!.brand == 'Samsung') {
      await _samsungService.launchApp(appId);
    } else if (_activeDevice!.brand == 'LG') {
      await _lgService.launchApp(appId);
    }
  }

  /// Desconectar
  void disconnect() {
    _samsungService.disconnect();
    _lgService.disconnect();
    _activeDevice = null;
    notifyListeners();
  }

  /// Eliminar dispositivo guardado
  Future<void> removeDevice(TvDevice device) async {
    _savedDevices.removeWhere((d) => d.id == device.id);
    if (_activeDevice?.id == device.id) {
      disconnect();
    }
    await _saveDevices();
    notifyListeners();
  }

  void _updateLocalState(RemoteCommand command) {
    switch (command) {
      case RemoteCommand.volumeUp:
        _currentVolume = (_currentVolume + 1).clamp(0, 100);
        _isMuted = false;
        break;
      case RemoteCommand.volumeDown:
        _currentVolume = (_currentVolume - 1).clamp(0, 100);
        _isMuted = false;
        break;
      case RemoteCommand.mute:
        _isMuted = !_isMuted;
        break;
      default:
        break;
    }
  }

  Future<void> _loadSavedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devicesJson = prefs.getStringList('devices') ?? [];
    _savedDevices = devicesJson
        .map((json) => TvDevice.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devicesJson = _savedDevices
        .map((device) => jsonEncode(device.toJson()))
        .toList();
    await prefs.setStringList('devices', devicesJson);
  }

  @override
  void dispose() {
    _samsungService.dispose();
    _lgService.dispose();
    super.dispose();
  }
}
