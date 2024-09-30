import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unsplish_api_img/firebase_options.dart';
import 'package:unsplish_api_img/splish_screen/splish_screen.dart';
import 'package:unsplish_api_img/view/homepage.dart';
import 'package:unsplish_api_img/view/login_page.dart';
import 'package:unsplish_api_img/view/sign_up_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only once with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      routes: {
        '/': (context) => const SplashScreen(
          
          child: LoginPage(),
        ),
        '/login': (context) =>const  LoginPage(),
        '/signUp': (context) =>const SignUpPage(),
        '/home': (context) =>  HomePage(),
      },
    );
  }
}