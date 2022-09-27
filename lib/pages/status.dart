import 'package:band_names_udemy/services/socket_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Status del Servidor: ${socketService.statusconnection}'),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.nordic_walking_rounded),
          onPressed: () {
            socketService.socket.emit('emitir-mensaje', {'nombre: ' 'Flutter'});
          }),
    );
  }
}
