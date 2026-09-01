import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nativeapi/nativeapi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Container());
  final window = WindowManager.instance.getCurrent();
  print("Window is: $window");
  window?.titleBarStyle = TitleBarStyle.hidden;
}
