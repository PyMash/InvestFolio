import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:investfolio/HomePage/home_page.dart';
import 'package:investfolio/NavBar/MainPage.dart';
import 'forget_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String name = "";
  bool loading = false;
  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  //Google Sign In
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // User signed in successfully
        print('User signed in: ${user.displayName}, ${user.email}');
        print('Profile Picture URL: ${user.photoURL}');

        // Update Firestore database with user information
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'Name': user.displayName,
          'email': user.email,
          'profilepicture': user.photoURL ?? '',
        });
      } else {
        // Handle sign-in failure
        print('Sign-in failed.');
      }

      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(
      //     backgroundColor: Colors.transparent,
      //     automaticallyImplyLeading: false,
      //     elevation: 0,
      //     iconTheme: IconThemeData(color: Colors.black),
      //     leading: Align(
      //       alignment: Alignment(-1.0, 0.0),
      //       child: Padding(
      //         padding: const EdgeInsets.only(left: 12.0, top: 10),
      //         child: IconButton(
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //           icon: Icon(
      //             Icons.arrow_back_ios_new,
      //             size: 25,
      //           ),
      //         ),
      //       ),
      //     )),
      body: Form(
        key: formKey,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEBF1ED).withOpacity(0.1), // #EBF1ED
                Color(0xFFEBF1ED).withOpacity(0.4), // #EBF1ED
                Color(0xFFEBF1ED).withOpacity(0.7), // #EBF1ED
                Color(0xFF374e3a).withOpacity(0.8), // #394747
              ],
            ),
          ),
          // height: MediaQuery.of(context).size.height / 1.2,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "InvestFolio",
              style: GoogleFonts.orbitron(
                  fontSize: 34,
                  letterSpacing: 5,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 6, 36, 8)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                "- SIGN IN -",
                style: GoogleFonts.orbitron(
                    fontSize: 12,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 6, 36, 8)),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.3,
              child: TextFormField(
                controller: _username,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(10.0),
                    isDense: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 6, 36, 8), width: 1.5),
                    ),
                    filled: true,
                    hintText: 'Email ID',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(45))),
                validator: (value) {
                  if (value!.isEmpty ||
                      !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                    return "Invalid Email Format";
                  } else {
                    return null;
                  }
                },
              ),
            ),
            SizedBox(
              height: 7,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.3,
              child: TextFormField(
                  obscureText: true,
                  controller: _password,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(10.0),
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(45),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 6, 36, 8), width: 1.5),
                      ),
                      filled: true,
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(45),
                      )),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password should not be empty";
                    } else {
                      return null;
                    }
                  }),
            ),
            SizedBox(
              height: 30,
            ),
            loading
                ? const CircularProgressIndicator(
                    color: Color.fromARGB(255, 6, 36, 8),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width / 2.6,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        if (formKey.currentState!.validate()) {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _username.text.trim(),
                              password: _password.text.trim(),
                            );
                            await _secureStorage.write(
                                key: 'passcode', value: '');
                            if (context != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainPage(),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.message ==
                                'There is no user record corresponding to this identifier. The user may have been deleted.') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: Color(0xFF062408),
                                      content: Text(
                                        'User not found',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.orbitron(
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            } else if (e.message ==
                                'The password is invalid or the user does not have a password.') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: Color(0xFF062408),
                                      content: Text(
                                        'Password Incorrect',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.orbitron(
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            } else if (e.message ==
                                'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor:
                                          Color.fromARGB(255, 6, 36, 8),
                                      content: Text(
                                        'Check your internet',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.orbitron(
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor:
                                          const Color.fromARGB(255, 6, 36, 8),
                                      content: Text(
                                        'Contact Support Team With Error Details"${e.message.toString()}"',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.orbitron(
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )));
                            }

                            print(e);
                          }
                        }
                        setState(() {
                          loading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 6, 36, 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                      child: Text('Sign In',
                          style: GoogleFonts.orbitron(
                              fontSize: 13,
                              wordSpacing: 1,
                              letterSpacing: 1,
                              color: Colors.white)),
                    ),
                  ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' - - - - - -  or  - - - - - - ',
                  style: GoogleFonts.orbitron(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () async {
                  User? user = await _handleSignIn();
                  if (user != null) {
                    // User signed in successfully
                    print('User signed in: ${user.displayName}, ${user.email}');
                    print('Profile Picture URL: ${user.photoURL}');
                  } else {
                    // Handle sign-in failure
                    print('Sign-in failed.');
                  }
                },
                child: Image.asset('img/gicon.png')),
            SizedBox(
              height: 20,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 128),
              child: Divider(
                color: Color.fromARGB(255, 3, 20, 4),
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  _createRoute(ForgetPasswordPage()),
                );
              },
              child: Text(
                'Forget your password ?',
                style: GoogleFonts.orbitron(
                    fontSize: 13,
                    letterSpacing: 0.2,
                    // fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 1, 15, 1)),
              ),
            ),

            // Expanded(
            //   child: Align(
            //     alignment: FractionalOffset.bottomCenter,
            //     child: Padding(
            //       padding: const EdgeInsets.only(bottom:38.0),
            //       child: IconButton(
            //         icon: Icon(
            //           Icons.arrow_back_ios,
            //           color: Color.fromARGB(255, 6, 36, 8),
            //           size: 28,
            //         ),
            //         onPressed: () {
            //           Navigator.pop(context);
            //         },
            //       ),
            //     ),
            //   ),
            // ),
          ]),
        ),
      ),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
