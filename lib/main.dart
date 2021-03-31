import 'package:flutter/material.dart';
import 'package:mapupdate_app/ui/map_screen.dart';
import 'package:mapupdate_app/view_model/map_screen_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => MapScreenViewModel(),
        child: MapScreen(),
      ),
    );
  }
}

