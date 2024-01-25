import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'sign_in_page.dart';
import 'sign_up_page.dart';

class OpeningPage extends StatefulWidget {
  const OpeningPage({Key? key}) : super(key: key);

  @override
  State<OpeningPage> createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.1))
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEBF1ED).withOpacity(0.001), // #EBF1ED
            Color(0xFFEBF1ED), // #EBF1ED
            Color(0xFFEBF1ED), // #EBF1ED
            Color(0xFFEBF1ED), // #EBF1ED
            Color.fromARGB(255, 195, 214, 214), // #394747
            Color(0xFF394747), // #394747
          ],
        ),
      ),
    ),
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('img/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              children: [
                buildOpeningContent(),
                SignInPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOpeningContent() {
    return Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 155),
          child: Text(
            "InvestFolio",
            style: GoogleFonts.orbitron(
              fontSize: 38,
              letterSpacing: 5,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 6, 36, 8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            "- Your Wealth, Our Expertise -",
            style: GoogleFonts.orbitron(
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 6, 36, 8),
            ),
          ),
        ),
        SizedBox(height: 80),
        Container(
          width: MediaQuery.of(context).size.width / 3,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF062408),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(
              'Sign In',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                wordSpacing: 1,
                letterSpacing: 1,
                color: Colors.white
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width /3,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                _createRoute(SignUpPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 6, 36, 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(
              'Sign Up',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                wordSpacing: 1,
                letterSpacing: 1,
                color: Colors.white
              ),
            ),
          ),
        ),
        SizedBox(height: 85),
        AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) {
            return SlideTransition(
              position: _animation,
              child: Column(
                children: [
                  Transform.rotate(
                    angle: 90 * math.pi / 180,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white.withOpacity(0.6),
                      size: 26,
                    ),
                  ),
                  Transform.rotate(
                    angle: 90 * math.pi / 180,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
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
}
