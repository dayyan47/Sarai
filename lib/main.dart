import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/Screens/Splash_Screen.dart';
import 'package:hostel_add/firebase_options.dart';
import 'package:hostel_add/resources/values/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SARAI',
      theme: ThemeData(
        primaryColor: AppColors.PRIMARY_COLOR,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.PRIMARY_COLOR),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
