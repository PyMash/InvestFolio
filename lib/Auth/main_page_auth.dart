import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:investfolio/Auth/lockScreenCheck.dart';
import 'package:investfolio/Basic/email_verify_page.dart';
import 'package:investfolio/HomePage/home_page.dart';

import '../NavBar/MainPage.dart';
import 'auth_page.dart';

class MainPageAuth extends StatelessWidget {
  const MainPageAuth({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User? user = snapshot.data;

            if (user != null) {
              if (user.emailVerified) {
                // User's email is verified, proceed to LockScreenCheck
                return const LockScreenCheck();
              } else {
                // User's email is not verified, redirect to VerifyEmailPage
                return  VerificationPage();
              }
            } else {
              // User is not authenticated, redirect to AuthPage
              return const AuthPage();
            }
          } else {
            // No user data, redirect to AuthPage
            return const AuthPage();
          }
        },
      ),
    );
  }
}
