import 'package:fastinv/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './home/ui/home.dart';
import './home/login.dart';
import './profiles.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

MyUser globalUser = MyUser(null);

class _MyAppState extends State<MyApp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  MyUser user = MyUser(null);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(myuser: user, auth: auth),
        '/home': (context) {
          globalUser = user;
          return HomeScreen();
        },
      },
      // home: HomeScreen(),
      // home: LoginPage(),
    );
  }
}
