import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>(); //key for form
  String name = "";
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            child: Center(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height/1.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Text(
                              'Enter your email address to reset your password',
                              style: GoogleFonts.orbitron(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 1),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),Container(
                                  width: MediaQuery.of(context).size.width / 1.3,
                                  child: TextFormField(
                                    controller: _emailController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.all(10.0),
                                        isDense: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(45),
                                          borderSide: const BorderSide(
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
                          const SizedBox(
                            height: 18,
                          ),
                          loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 6, 36, 8)),
                                )
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width / 2.2,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () async{
                                      setState(() {
                                        loading = true;
                                      });
                                      
                                      if (formKey.currentState!.validate()) {
                                        try {
                                          await FirebaseAuth.instance
                                              .sendPasswordResetEmail(
                                                  email: _emailController.text.trim());
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return const AlertDialog(
                                                  content: Text(
                                                      'Password reset link send! check your email',textAlign: TextAlign.center ,style: TextStyle(color:Color.fromARGB(255, 6, 36, 8), ),),
                                                );
                                              });
                                          Timer(const Duration(seconds: 3), () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const MyApp()));
                                          });
                                        } on FirebaseAuthException catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                  backgroundColor: Color.fromARGB(255, 6, 36, 8),
                                                  content: Text(
                                                    e.message.toString(),textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )));
                                        }
                                      }
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 6, 36, 8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0)),
                                    ),
                                    child: Text('Reset',
                                        style: GoogleFonts.orbitron(
                                            fontSize: 10, letterSpacing: 2,color: Colors.white)),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Expanded(
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom:38.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: Color.fromARGB(255, 6, 36, 8),
                                    size: 28,
                                  ),
                                  onPressed: () {
                                      Navigator.pop(context);
                                    
                                  },
                                ),
                              ),
                            ),
                          ),            ],
                ),          
              ),
            ),
          ),
        ],
      ),
    );
  }
}
