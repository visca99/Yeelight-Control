import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yeelight_control/Models/yeelight.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:window_size/window_size.dart';

class Screen extends StatefulWidget {
  const Screen() : super();

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  List<Yeelight> _bulbs = [];

  void toggleStatus(Yeelight lamp) {
    lamp.status = !lamp.status;
    Socket.connect(lamp.ip, 55443).then((sock) {
      sock.write("{\"id\":1,\"method\":\"toggle\",\"params\":[]}\r\n");
      sock.close();
      setState(() {});
    });
  }

  Future<void> yeelightSearch() async {
    _bulbs.clear();
    //MULTICAST DISCOVER
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 1982)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((e) async {
        Datagram? dg = udpSocket.receive();
        if (dg != null) {
          String rawData = String.fromCharCodes(dg.data);
          //dynamic jsondata = jsonDecode(rawData);
          //print(rawData);
          //print("\n\r");
          InternetAddress ip = InternetAddress(rawData.substring(
              rawData.indexOf("Location: yeelight://") + 21,
              rawData.indexOf(
                  ":", rawData.indexOf('Location: yeelight://') + 21)));
          String name = rawData.substring(rawData.indexOf("name: ") + 6,
              rawData.indexOf("\r\n", rawData.indexOf("name: ") + 6));
          bool status;
          if (rawData.substring(rawData.indexOf("power: ") + 7,
                  rawData.indexOf("\r\n", rawData.indexOf("power: ") + 7)) ==
              "on") {
            status = true;
          } else {
            status = false;
          }

          Yeelight newBulb = Yeelight(name: name, ip: ip, status: status);

          if (_bulbs.indexOf(newBulb) == -1) {
            setState(() {
              _bulbs.add(newBulb);
            });
            if (_bulbs.length == 1) {
              setWindowMinSize(Size(300, 200));
              setWindowMaxSize(Size(300, 200));
            } else {
              setWindowMinSize(Size(_bulbs.length * 150, 200));
              setWindowMaxSize(Size(_bulbs.length * 150, 200));
            }
          }
        }
      });
      List<int> multicastSearch = utf8.encode(
          "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1982\r\nMAN: \"ssdp:discover\"\r\nST: wifi_bulb");
      udpSocket.send(multicastSearch, InternetAddress("239.255.255.250"), 1982);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      setWindowTitle("Yeelight Control");
      await yeelightSearch();
    });
    super.initState();
  }

  Future<bool?> _changeNameDialog(BuildContext context, Yeelight bulb) async {
    String _newName = "";
    var _changeNameFormKey = GlobalKey<FormState>();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Change Name",
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800]),
          ),
          titlePadding: EdgeInsets.only(left: 20, top: 20),
          contentPadding: EdgeInsets.only(top: 10, left: 18, right: 18),
          content: SingleChildScrollView(
            child: Form(
              key: _changeNameFormKey,
              child: TextFormField(
                style: TextStyle(fontSize: 18),
                onChanged: (value) {
                  setState(() {
                    _newName = value;
                  });
                },
                validator: (input) {
                  if (input!.isEmpty) return "Insert a name!";
                  return null;
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 12),
                  labelText: 'new name',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  isDense: true,
                  labelStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("CANCEL", style: TextStyle(fontSize: 15)),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text("SET", style: TextStyle(fontSize: 15)),
              onPressed: () async {
                if (_changeNameFormKey.currentState!.validate()) {
                  _bulbs[_bulbs.indexOf(bulb)].name = _newName;
                  Socket.connect(bulb.ip, 55443).then((sock) {
                    sock.write(
                        "{\"id\":1,\"method\":\"set_name\",\"params\":[\"$_newName\"]}\r\n");
                    sock.close();
                  }).whenComplete(() {
                    Navigator.pop(context, true);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeelight Control"),
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                await yeelightSearch();
              },
              icon: Icon(Icons.refresh)),
        ],
      ),
      body: Container(
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _bulbs.length,
            itemBuilder: (BuildContext buildcontext, int index) {
              return Container(
                width: 150,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  margin: EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: TextButton(
                          child: Text(
                            _bulbs[index].name != ""
                                ? _bulbs[index].name
                                : "CLICK TO RENAME",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800]),
                          ),
                          onPressed: () {
                            _changeNameDialog(context, _bulbs[index])
                                .then((value) {
                              if (value != null && value) {
                                setState(() {});
                              }
                            });
                          },
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height) *
                            0.08,
                        child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.lightbulb,
                              color: _bulbs[index].status
                                  ? Colors.yellow[700]
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              toggleStatus(_bulbs[index]);
                            },
                            iconSize: 38,
                            splashRadius: 30,
                            splashColor: Colors.yellow,
                            hoverColor: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
