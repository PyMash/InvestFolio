import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   centerTitle: true,
        //   title: Text(
        //     'About ',
        //     style: GoogleFonts.poppins(
        //         color: Colors.black, fontSize: 18, letterSpacing: 1.5),
        //   ),
        //   iconTheme: IconThemeData(
        //     color: Colors.black, // Replace yourColor with the desired color
        //   ),
        // ),
        body: Stack(children: [
      Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/invst.jpg'),
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
              const Color(0xFFEBF1ED).withOpacity(0.5),
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.5),
              const Color.fromARGB(255, 195, 214, 214).withOpacity(0.2),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.08,
                ),
                Text(
                  'Invest Folio',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.redHatDisplay(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.07),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "InvestFolio is your go-to app for seamless investment tracking, designed to empower users to effortlessly manage and monitor their investment portfolios. Whether you're a seasoned investor or just starting your journey, InvestFolio provides a user-friendly platform for keeping a close eye on your investments.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      letterSpacing: 1,
                      // fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.035),
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  'About the Developer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.redHatDisplay(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.055),
                ),
                const SizedBox(
                  height: 8,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        "As the sole developer of InvestFolio, I am a dedicated Computer Science student named ",
                    style: GoogleFonts.poppins(
                        letterSpacing: 1,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Colors.black),
                    children: <TextSpan>[
                      const TextSpan(
                        text: "Mashud Ahmed Talukdar",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const TextSpan(
                        text:
                            ". I combine technical expertise with a deep understanding of the user experience, ensuring the app meets the diverse needs of its users.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'You can reach me at',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.040),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'https://github.com/PyMash',
                  style: GoogleFonts.poppins(
                      letterSpacing: 1,
                      // height: 1,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.032),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'mashudworkmail@gmail.com',
                      style: GoogleFonts.poppins(
                          letterSpacing: 1.2,
                          height: 1,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.034),
                    ),
                    // SizedBox(width: 10,),
                    // GestureDetector(
                    //   onTap: (){
                    //      Clipboard.setData(const ClipboardData(
                    //           text: 'mashudworkmail@gmail.com'));
                    //       ScaffoldMessenger.of(context)
                    //           .showSnackBar(const SnackBar(
                    //         content: Text(
                    //           'Copied email address',
                    //           textAlign: TextAlign.center,
                    //         ),
                    //         duration: Duration(seconds: 1),
                    //       ));
                    //   },
                    //   child: Icon(
                    //         Icons.copy,
                    //         size: MediaQuery.of(context).size.width * 0.05,
                    //       ),
                    // )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.08,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_sharp))
              ],
            ),
          ),
        ),
      ),
    ]));
  }
}
