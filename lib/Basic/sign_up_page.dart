import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:investfolio/HomePage/home_page.dart';
import 'package:investfolio/NavBar/MainPage.dart';

import 'email_verify_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final _username = TextEditingController();
  final _emailId = TextEditingController();
  final _password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String name = "";
  bool loading = false;
  @override
  void dispose() {
    _emailId.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future addUserDetails(String name, String email, String password) async {
    await FirebaseFirestore.instance.collection('users').add({
      'Name': name,
      'email': email,
      'password': password,
    });
  }

  //Google sign in

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
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

  Future<void> sendEmailVerification() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await user.sendEmailVerification();
    print('Verification email sent to ${user.email}');
  } else {
    print('No user is currently signed in.');
    // Handle the case where no user is signed in
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf4f4f2),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          leading: Align(
            alignment: Alignment(-1.0, 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 25,
                ),
              ),
            ),
          )),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('img/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEBF1ED).withOpacity(0.1), // #EBF1ED
                  Color(0xFFEBF1ED).withOpacity(0.4), // #EBF1ED
                  // Color(0xFFEBF1ED).withOpacity(0.4), // #EBF1ED
                  // Color(0xFFEBF1ED).withOpacity(0.5), // #EBF1ED
                  // Color(0xFF374e3a).withOpacity(0.8), // #394747// #394747
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Form(
                    key: formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                              "- SIGN UP -",
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
                                        color: Color.fromARGB(255, 6, 36, 8),
                                        width: 1.5),
                                  ),
                                  filled: true,
                                  hintText: 'Name',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(45))),
                              validator: (value) {
                                if (value!.isEmpty ||
                                    !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                                  return "Invalid Format";
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
                              controller: _emailId,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(10.0),
                                  isDense: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(45),
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 6, 36, 8),
                                        width: 1.5),
                                  ),
                                  filled: true,
                                  hintText: 'Email ID',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(45))),
                              validator: (value) {
                                if (value!.isEmpty ||
                                    !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(value)) {
                                  return "Invalid Format";
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
                                controller: _password,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.all(10.0),
                                    isDense: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(45),
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(255, 6, 36, 8),
                                          width: 1.5),
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
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 6, 36, 8)),
                                )
                              : Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.6,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      if (formKey.currentState!.validate()) {
                                        try {
                                          await FirebaseAuth.instance
                                              .createUserWithEmailAndPassword(
                                                  email: _emailId.text.trim(),
                                                  password:
                                                      _password.text.trim());
                                          final user = FirebaseAuth
                                              .instance.currentUser!;

                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .set({
                                            'Name': _username.text.trim(),
                                            'email': _emailId.text.trim(),
                                            'password': _password.text.trim(),
                                            'profilepicture': '',
                                          });
                                          await _secureStorage.write(
                                              key: 'passcode', value: '');
                                          await sendEmailVerification();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VerificationPage()),
                                          );
                                        } on FirebaseAuthException catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 6, 36, 8),
                                                  content: Text(
                                                    e.message.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.orbitron(
                                                        fontSize: 12,
                                                        letterSpacing: 0.5,
                                                        // fontWeight: FontWeight.bold,
                                                        color: Colors.white),
                                                  )));
                                        }
                                      }
                                      if (mounted) {
                                        setState(() {
                                          loading = false;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF062408),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                    ),
                                    child: Text('Sign Up',
                                        style: GoogleFonts.orbitron(
                                            fontSize: 13,
                                            wordSpacing: 1,
                                            letterSpacing: 1,
                                            color: Colors.white)),
                                  ),
                                ),
                          SizedBox(
                            height: 20,
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
                                print('Clicked');
                                User? user = await _handleSignIn();
                                if (user != null) {
                                  // User signed in successfully
                                  print(
                                      'User signed in: ${user.displayName}, ${user.email}');
                                } else {
                                  // Handle sign-in failure
                                  print('Sign-in failed.');
                                }
                              },
                              child: Image.asset('img/gicon.png'))
                          // Expanded(
                          //   child: Align(
                          //     alignment: FractionalOffset.bottomCenter,
                          //     child: Padding(
                          //       padding: const EdgeInsets.only(bottom: 38.0),
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
