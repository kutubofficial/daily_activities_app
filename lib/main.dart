import 'package:day_flow/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:day_flow/models/activity.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized(); 
  await Hive.initFlutter();
  Hive.registerAdapter(ActivityAdapter());
  await Hive.openBox<Activity>('activities');
  runApp(const FlutterApp());

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("c0d9fa5e-6ac8-49fd-921c-64b8f4b32735");
  OneSignal.Notifications.requestPermission(true);
}

class FlutterApp extends StatelessWidget {
  const FlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Daily Activities',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const DashBoardScreen(),
    );
  }
}
