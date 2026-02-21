import 'dart:ui';

import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/core/rasp_service.dart';
import 'package:chronoflow/firebase_options.dart';
import 'package:chronoflow/pages/auth_screen.dart';
import 'package:chronoflow/pages/check_in_screen.dart';
import 'package:chronoflow/pages/event_screen.dart';
import 'package:chronoflow/pages/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await RaspService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitle,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Placeholder(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.unknown,
        },
      ),
      initialRoute: Constants.authScreen,
      routes: {
        Constants.authScreen: (context) => const AuthScreen(),
        Constants.eventScreen: (context) => const EventScreen(),
        Constants.registrationScreen: (context) => const RegistrationScreen(),
        Constants.checkInScreen: (context) => const CheckInScreen(),
      },
    );
  }
}
