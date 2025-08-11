import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<List<ConnectivityResult>> _connectionController =
      StreamController<List<ConnectivityResult>>.broadcast();

  bool _isOnline = false;
  List<ConnectivityResult> _currentResults = [];

  bool get isOnline => _isOnline;
  List<ConnectivityResult> get currentResults => _currentResults;

  Stream<List<ConnectivityResult>> get connectionStream =>
      _connectionController.stream;

  Future<void> initialize() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _currentResults = results;
    _isOnline = results.any((result) => result != ConnectivityResult.none);

    _connectionController.add(results);

    if (kDebugMode) {
      print('Network Status: ${_isOnline ? 'Online' : 'Offline'}');
      print('Available connections: ${results.join(', ')}');
    }
  }

  bool hasWifi() {
    return _currentResults.contains(ConnectivityResult.wifi);
  }

  bool hasMobile() {
    return _currentResults.contains(ConnectivityResult.mobile);
  }

  bool hasEthernet() {
    return _currentResults.contains(ConnectivityResult.ethernet);
  }

  void dispose() {
    _connectionController.close();
  }
}
