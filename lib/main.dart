import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  // AwesomeNotifications().initialize(
  //   'resource://drawable/res_app_icon',
  //   [
  //     NotificationChannel(
  //       channelKey: 'basic_channel',
  //       channelName: 'Basic notifications',
  //       channelDescription: 'Notification channel for basic tests',
  //       defaultColor: Color(0xFF9D50DD),
  //       ledColor: Colors.white,
  //       importance: NotificationImportance.High,
  //     )
  //   ],
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'ToDo App',
      home: Home(),
    );
  }
}
