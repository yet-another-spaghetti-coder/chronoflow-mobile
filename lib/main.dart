import 'package:chronoflow/core/di/service_locator.dart';
import 'package:chronoflow/features/app/app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MainApp());
}
