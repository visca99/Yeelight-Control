import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yeelight_control/Models/yeelight.dart';

class MoreSettings extends StatefulWidget {
  const MoreSettings({Key? key, required this.bulb}) : super(key: key);

  final Yeelight bulb;

  @override
  _MoreSettingsState createState() => _MoreSettingsState();
}

class _MoreSettingsState extends State<MoreSettings> {
  late double selectedBright;

  @override
  void initState() {
    selectedBright = widget.bulb.bright.toDouble();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "Change Brightness",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
          ),
          Slider(
            value: selectedBright,
            min: 0,
            max: 100,
            divisions: 10,
            label: "${selectedBright.toString()}%",
            onChanged: (double value) {
              setState(() {
                if (value == 0) {
                  selectedBright = 1;
                } else {
                  selectedBright = value;
                }

                Socket.connect(widget.bulb.ip, 55443).then((sock) {
                  sock.write(
                      "{\"id\":1,\"method\":\"set_power\",\"params\":[\"on\", \"smooth\", 500]}\r\n");
                  sock.write(
                      "{\"id\":1,\"method\":\"set_bright\",\"params\":[$selectedBright]}\r\n");
                  sock.close();
                });
              });
            },
          ),
        ],
      )),
    );
  }
}
