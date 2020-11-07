import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_my_radio_app/radioItem.dart';
import 'package:http/http.dart' as http;

class radioMain extends StatefulWidget {
  @override
  _radioMainState createState() => _radioMainState();
}

class _radioMainState extends State<radioMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Radyo Seçim Ekranı",
      )),
      body: menuBody(),
    );
  }

//  MyHomePage({Key key, this.title}) : super(key: key);
  Widget menuBody() {
    return Scaffold(body: _menuItems());
  }

  Future<List<radioItem>> _fetchStations() async {
    final response = await http
        .get("https://api.npoint.io/fa5ca1d2723d7fb43352")
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      List radios = json.decode(response.body);
      return radios.map((radio) => new radioItem.fromJson(radio)).toList();
    } else
      throw Exception('Failed to read');
  }

  Widget _menuItems() {
    return Center(
      child: FutureBuilder<List<radioItem>>(
          future: _fetchStations(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<radioItem> radioItems = snapshot.data;
              return new ListView(
                  children: radioItems
                      .map((radioItem) => _listItem(radioItem))
                      .toList());
            } else if (snapshot.hasError) {
              print(snapshot.error.toString());

              return Center(child: Text('Radyo bulunamadı.'));
            }
            //return Text('${snapshot.error}');
            return CircularProgressIndicator();
          }),
    );
  }

  Card _listItem(radioItem item) {
    return Card(
        child: ListTile(
      leading: Text("${item.lang}"),
      title: Text(
        '${item.title}',
        style: TextStyle(
          color: Colors.deepPurple,
        ),
      ),
      subtitle: Text('${item.kategori}', style: TextStyle(color: Colors.blue)),
      onTap: () {
        print("${item.stream_path} ");
      },
    ));
  }
}
