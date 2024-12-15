import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:investfolio/Auth/lockScreenCheck.dart';
import 'package:investfolio/Basic/opening_page.dart';
import 'package:investfolio/Basic/sign_up_page.dart';
import 'package:investfolio/HomePage/home_page.dart';
import 'package:investfolio/main.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start checking every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      checkEmailVerificationStatus();
    });
  }

  int CheckEmail = 0;

  Future<void> checkEmailVerificationStatus() async {
    CheckEmail += 1;
    if (CheckEmail < 5) {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user!.emailVerified) {
        // Navigate to the home page if email is verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LockScreenCheck()),
        );
        // Cancel the timer since we no longer need to check
        _timer.cancel();
      } else {
        print('Email not verified yet.');
      }
    } else {
      print('Auto Redirect Stopped');
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
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

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> deleteCurrentUserAndData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Delete the user from Firebase Authentication
        await user.delete();

        // Delete the user data from Firestore (replace with your Firestore details)
        String documentId = user.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .delete();

        print('User and associated data deleted successfully.');
      } else {
        print('No user is currently signed in.');
        // Handle the case where no user is signed in
      }
    } catch (error) {
      print('Error deleting user and data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.attach_email_outlined,
                size: MediaQuery.of(context).size.width * 0.15,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Verify your email address',
                style: GoogleFonts.poppins(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width * 0.045),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                user!.email.toString(),
                style: GoogleFonts.poppins(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.03),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'We have just send email verification link on your email.please check email and click on that link to verify your email address.\n\nIf not auto redirected after verification, click on the Continue button',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.035),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;
                    await user!.reload();
                    user = FirebaseAuth.instance.currentUser;
                    if (user!.emailVerified) {
                      _timer.cancel();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LockScreenCheck()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Email not verified yet',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              letterSpacing: 1, color: Colors.white),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.black,
                      ));
                    }
                  },
                  child: Text(
                    'Continue',
                    style: GoogleFonts.redHatDisplay(
                        color: Colors.black,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500),
                  )),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () async {
                    await sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'E-mail Send',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            letterSpacing: 1, color: Colors.white),
                      ),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.black,
                    ));
                  },
                  child: Text(
                    'Resend E-Mail Link',
                    style: GoogleFonts.redHatDisplay(
                        letterSpacing: 1,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500),
                  )),
              SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () async {
                  _timer.cancel();
                  await deleteCurrentUserAndData();
                  await FirebaseAuth.instance.signOut();
                  if (context != null && Navigator.of(context).canPop()) {
                    // There is a route to pop, so popping won't result in a blank screen
                    Navigator.of(context).pop();
                  } else {
                    // There are no more routes to pop, which means popping will result in a blank screen
                    // You can handle this case accordingly
                    if (kDebugMode) {
                      print('Popping will result in a blank screen');
                    }
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const OpeningPage();
                      },
                    ));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: MediaQuery.of(context).size.width * 0.04,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Change Email',
                      style: GoogleFonts.redHatDisplay(
                          color: Colors.blue,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.039),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
