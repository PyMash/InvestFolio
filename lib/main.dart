import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investfolio/Basic/email_verify_page.dart';

import 'Auth/main_page_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: 'AIzaSyD86A_M9xlqRqq_4B4gyJj1h6zztEmFOko',
            appId: '1:749432039174:web:81b191dedf4d4891862087',
            messagingSenderId: '749432039174',
            projectId: 'investfolio-6dabc',
            storageBucket: 'investfolio-6dabc.appspot.com'));
  } else {
    await Firebase.initializeApp();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.green.shade900,
          inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade900))),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.green.shade900,
              selectionHandleColor: Colors.green.shade900,
              selectionColor: Colors.green.shade100),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.black))),
          progressIndicatorTheme:
              ProgressIndicatorThemeData(color: Colors.green.shade900),
          snackBarTheme: SnackBarThemeData(
              backgroundColor: Colors.green.shade900,
              contentTextStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500))),
      home: MainPageAuth(),
      // home: VerificationPage(),
    );
  }
}
