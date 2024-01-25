import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';

class ResetPasscode extends StatefulWidget {
  const ResetPasscode({super.key});

  @override
  State<ResetPasscode> createState() => _ResetPasscodeState();
}

class _ResetPasscodeState extends State<ResetPasscode> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('img/invst2.jpg'),
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
                  const Color(0xFFEBF1ED).withOpacity(0.5),
                  const Color(0xFFEBF1ED).withOpacity(0.3),
                  const Color(0xFFEBF1ED).withOpacity(0.3),
                  const Color(0xFFEBF1ED).withOpacity(0.2),
                  const Color.fromARGB(255, 195, 214, 214).withOpacity(0.3),
                  const Color.fromARGB(255, 195, 214, 214).withOpacity(0.5),
                ],
              ),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "For security purposes, resetting your passcode requires a brief logout and re-login process. Click on the Login Again button, and this will trigger the reset, and you'll be able to set a new passcode later on.",
                    style: GoogleFonts.poppins(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _secureStorage.write(key: 'passcode', value: '');
                        await googleSignIn.signOut(); // Sign out from Google
                        await _auth.signOut(); // Sign out from Firebase

                        FirebaseAuth.instance
                            .signOut()
                            .then((value) => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MyApp()), // Your new screen
                                  (Route<dynamic> route) =>
                                      false, // Remove all previous routes
                                ));

                        // Optionally, you can also clear the user's information from Firestore if needed
                        // await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid).delete();

                        // Navigate back to the sign-up page or any other desired screen
                        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUpPage()));
                      } catch (error) {
                        print(error.toString());
                      }
                    },
                    child: Text(
                      'Login Again',
                      style: GoogleFonts.poppins(letterSpacing: 1),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
