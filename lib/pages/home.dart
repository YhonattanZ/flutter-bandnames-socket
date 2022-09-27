import 'dart:io';

import 'package:band_names_udemy/models/band_name.dart';
import 'package:band_names_udemy/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketservice = Provider.of<SocketService>(context, listen: false);

    socketservice.socket.on('active-bands', _handlerActiveBand);
    super.initState();
  }

  _handlerActiveBand(dynamic payload) {
    this.bands = (payload as List).map((banda) => Band.fromMap(banda)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketservice = Provider.of<SocketService>(context, listen: false);
    socketservice.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketservice = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0))),
        title: Text('BandNames'),
        elevation: 0,
        backgroundColor: Color(0xff0A8E84),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketservice.statusconnection == ServerStatus.Online)
                ? Icon(Icons.check_circle_outline, color: Colors.white)
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _Graph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => bandTile(bands[index])),
          )
        ],
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: addNewBand),
    );
  }

  Widget bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        socketService.socket.emit('delete-band', {'id': band.id});
        //TODO: llamar al borrado en el server
      },
      background: Container(
        //Personalizamos la acción del dismissible
        padding: EdgeInsets.only(left: 10.0),
        color: Colors.red.shade200,
        alignment: Alignment.centerLeft,
        child: Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name.substring(0, 2)),
            backgroundColor: Colors.blue.shade100,
          ),
          title: Text(band.name),
          trailing: Text('${band.votes}', style: TextStyle(fontSize: 18)),
          onTap: () {
            socketService.socket.emit('vote-band', {
              'id': band.id,
            });
            print(band.name);
          }),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New Band', style: TextStyle(color: Color(0xff0A8E84))),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                  child: Text(
                    'Add New Band',
                    style: TextStyle(color: Color(0xff0A8E84)),
                  ),
                  onPressed: () => addBand(textController.text)),
              MaterialButton(
                  child: Text(
                    'Get back',
                    style: TextStyle(color: Color(0xff0A8E84)),
                  ),
                  onPressed: () => Navigator.pop(context))
            ],
          );
        },
      );
    } else
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('New Band'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add new band'),
                    onPressed: () => addBand(textController.text)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.pop(context))
              ],
            );
          });
  }

  void addBand(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      //Podemos agregar una nueva banda
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  //Grafica
  Widget _Graph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
        padding: EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          chartValuesOptions: ChartValuesOptions(
              decimalPlaces: 0, showChartValuesInPercentage: true),
        ));
  }
}
