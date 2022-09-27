import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;

  IO.Socket _socket;

  ServerStatus get statusconnection => this._serverStatus;

  IO.Socket get socket => this._socket;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client - Socket port 3000
    this._socket = IO.io('http://192.168.250.6:4000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    this._socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
      print('Connected');
    });

    this._socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
      print('Disconnected');
    });

    /*  _socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje');
      print('nombre:' + payload['nombre']);
      print('mensaje:' + payload['mensaje']);
    });*/
  }
}
