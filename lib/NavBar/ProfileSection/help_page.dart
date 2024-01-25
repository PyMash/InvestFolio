import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Help and Support',
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 18, letterSpacing: 1.5),
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // Replace yourColor with the desired color
          ),
        ),
        body: Stack(children: [
      Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/invst2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.5),
              const Color(0xFFEBF1ED).withOpacity(0.5),
              const Color(0xFFEBF1ED).withOpacity(0.7),
              const Color(0xFFEBF1ED).withOpacity(0.7),
              const Color.fromARGB(255, 195, 214, 214).withOpacity(0.3),
              const Color.fromARGB(255, 195, 214, 214).withOpacity(0.5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Need any help or having any quory\n\nmail at',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  height: 1,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.035),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'investfolio.app@gmail.com',
                    style: GoogleFonts.poppins(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.036),
                  ),
                  IconButton(
                      onPressed: () {
                        Clipboard.setData(
                            const ClipboardData(text: 'investfolio.app@gmail.com'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                          'Copied email address',
                          textAlign: TextAlign.center,
                          
                        ),
                        duration: Duration(seconds: 1),));
                      },
                      icon:  Icon(
                        Icons.copy,
                        size:  MediaQuery.of(context).size.width * 0.05,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    ]));
  }
}
