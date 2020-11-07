import 'dart:convert';
import 'dart:async';
import 'dart:math';
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
  String playingStream="";
  String playingStreamUrl="";
  List radioList=[];
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
      radioList=radios;
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
          Container(margin: EdgeInsets.only(top: 10),child: playingStream.isEmpty?Text(""):Text("$playingStream",style: TextStyle(color: Colors.white),),),
          Row(children: <Widget>[
            Expanded(
              child: playIcon(),

            ),
            Expanded(child:shuffleButton(),),
            Expanded(child:GestureDetector(onTap:stopPressed,child: Icon(Icons.stop,size: MediaQuery.of(context).size.height/10)))
          ],

          )
        ],


      ),
    );
  }

  GestureDetector playIcon(){

    if (isPlaying)
      return GestureDetector(onTap:pausePressed ,child:Icon(Icons.pause,size: MediaQuery.of(context).size.height/10));
    else
      return GestureDetector(onTap:playPressed,child: Icon(Icons.play_arrow,size: MediaQuery.of(context).size.height/10));


  }

  Future<void> stationSelected(String _title,String _streamUrl) async {
    isPlaying=true;
    FlutterRadio.playOrPause(url: _streamUrl);
    playingStreamUrl=_streamUrl;
    playingStream=_title;
    setState(() {

    });
  }

  Future playingStatus() async {
    await FlutterRadio.isPlaying();

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

  void shufflePressed()
  async {
    Random random=new Random();
    int index=random.nextInt(radioList.length);

stationSelected(radioList[index]["title"], radioList[index]["stream_path"]);
  }
  Future<void> stopPressed() {
    isPlaying = false;
    playingStream="";
    playingStreamUrl="";
    FlutterRadio.stop();
    setState(() {

    });
  }

  Future<void> pausePressed() async {
    isPlaying = false;
    await FlutterRadio.pause(url: playingStreamUrl);
    setState(() {

    });
  }




  Future<void> playPressed() async {
    isPlaying = true;

    if(playingStreamUrl=="")
      shufflePressed();
    else
        await FlutterRadio.play(url: playingStreamUrl);
    setState(() {

    });
  }

  Widget shuffleButton() {
    return GestureDetector(onTap:shufflePressed,child: Icon(Icons.shuffle,size: MediaQuery.of(context).size.height/10));


  }
}
