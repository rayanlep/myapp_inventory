import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyUser {
  GoogleSignInAccount? user;
  MyUser(this.user);
  set setUser(GoogleSignInAccount? user) {
    this.user = user;
  }
}

class LoginPage extends StatefulWidget {
  FirebaseAuth auth;
  MyUser? myuser;
  LoginPage({required this.myuser, required this.auth, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            margin: EdgeInsets.only(top: 300),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 70),
                            child: Text("Fast Inventory",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.blue[700])),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 70),
                            child: Text(
                              "Inventory Management",
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          )
                        ],
                      ),
                      Container(
                        child: Icon(Icons.shopping_cart,
                            size: 50, color: Colors.orange[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 100),
                  child: SignInButton(
                    Buttons.google,
                    text: "continue with google",
                    onPressed: () async {
                      widget.myuser?.setUser = await HandleGoogleSignIn();

                      // Navigator.pushNamed(context, '/home');
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Future<GoogleSignInAccount?> HandleGoogleSignIn() async {
    late final GoogleSignInAccount? gUser;
    try {
      gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      final res = await widget.auth.signInWithCredential(credential);
      // GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      // UserCredential userCredential =
      //     await widget.auth.signInWithProvider(googleAuthProvider);
    } catch (e) {
      print("error");
      Navigator.pushNamed(context, '/login');
    }
    Navigator.pushNamed(context, '/home');

    return gUser;
  }
}
