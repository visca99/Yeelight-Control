import 'package:flutter/material.dart';
import 'package:yeelight_control/Models/yeelight.dart';
import 'package:yeelight_control/Screens/main_screen.dart';
import 'package:yeelight_control/Screens/more_settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yeelight Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/main_screen',
      routes: {
        '/main_screen': (context) => const MainScreen(),
        '/more_settings': (context) => MoreSettings(
            bulb: ModalRoute.of(context)!.settings.arguments as Yeelight),
      },
    );
  }
}
