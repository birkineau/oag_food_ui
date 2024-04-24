import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oag_food_ui/food_application.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    const MaterialApp(
      home: Scaffold(
        body: FoodApplication(),
      ),
    ),
  );
}
