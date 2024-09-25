
import 'package:flutter/material.dart';
import 'package:medapp/Important/CallChat.dart';
import 'package:medapp/Important/ChatApp.dart';
import 'package:medapp/Important/PerChat.dart';

import 'package:medapp/Login.dart';
import 'package:medapp/charts/DailySales.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      
        body: ChatApp(),
      ),
    );
  }
}
