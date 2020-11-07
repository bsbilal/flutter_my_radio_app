import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_my_radio_app/radioItem.dart';
import 'package:flutter_radio/flutter_radio.dart';
import 'package:http/http.dart' as http;

class radioMain extends StatefulWidget {
  @override
  _radioMainState createState() => _radioMainState();
}

class _radioMainState extends State<radioMain> {

  bool isPlaying=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Radyo Uygulamam",
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
    return
      Column(

        children: <Widget>[Expanded(
child:    Center(
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
),
flex: 5,
        ),
          Expanded(
            flex: 1,
child: _actionButtons(),
          )


        ],

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
      onTap: (){stationSelected(item.title,item.stream_path);},
    ));
  }

  Widget _actionButtons() {
    return Container(
      color: Colors.redAccent,
      child: Column(
        children: <Widget>[
          Container(margin: EdgeInsets.only(top: 10),child: Text("dfdsf",style: TextStyle(color: Colors.white),),),
          Row(children: <Widget>[
            Expanded(
              child: GestureDetector(child:playIcon()),

            ),
            Expanded(child:GestureDetector(child: Icon(Icons.stop,size: MediaQuery.of(context).size.height/10)))
          ],

          )
        ],


      ),
    );
  }

  Icon playIcon(){
    if (isPlaying)
      return Icon(Icons.pause,size: MediaQuery.of(context).size.height/10);
    else
      return Icon(Icons.shuffle,size: MediaQuery.of(context).size.height/10);
  }

  Future<void> stationSelected(String _title,String _streamUrl) async {
    isPlaying=true;
    FlutterRadio.playOrPause(url: _streamUrl);
    playingStatus();
    setState(() {

    });
  }

  Future playingStatus() async {
    bool isP = await FlutterRadio.isPlaying();
    setState(() {
      isPlaying = isP;
    });
  }
  Future<void> audioStart() async {
    await FlutterRadio.audioStart();
    print('Audio Start OK');
  }

  @override
  void initState() {
    super.initState();
    audioStart();
    playingStatus();
  }
}
