import 'dart:io';

import 'package:band_names_udemy/models/band_name.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Taylor Swift', votes: 10),
    Band(id: '2', name: 'Adele', votes: 20),
    Band(id: '3', name: 'Imagine Dragons', votes: 8),
    Band(id: '4', name: 'Given', votes: 5)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('BandNames'),
        elevation: 0,
        backgroundColor: Color(0xff0A8E84),
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, index) => bandTile(bands[index])),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: addNewBand),
    );
  }

  Widget bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: $direction');
        print('id: ${band.id}');
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
                  onPressed: () => addBand(textController.text))
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
    print(name);
    if (name.length > 1) {
      //Podemos agregar una nueva banda
      this
          .bands
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 5));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
