import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:investfolio/NavBar/mainPage.dart';

class SetPasscodePage extends StatefulWidget {
  String status;
  SetPasscodePage({Key? key, required this.status}) : super(key: key);

  @override
  State<SetPasscodePage> createState() => _SetPasscodePageState();
}

class _SetPasscodePageState extends State<SetPasscodePage> {
  String enteredPin = '';
  bool isPinVisible = false;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  _loadPasscode() async {
    String? storedPasscode = await _secureStorage.read(key: 'passcode');
    // Check if passcode is set for the first time
    if (storedPasscode == null) {
      // Set a default passcode (you can customize this logic)
      // storedPasscode = '1234';
      await _secureStorage.write(key: 'passcode', value: storedPasscode);
    }
  }

  _checkPasscode() async {
    String? storedPasscode = await _secureStorage.read(key: 'passcode');
    if (enteredPin == storedPasscode) {
      // Password is correct, navigate to HomePage
      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SetPasscodePage(
                      status: 'New',
                    ))); // Replace HomePage with your actual home page widget
      });
    } else {
      // Wrong Passcode, update the error message
      updateErrorMessage('Wrong Passcode, Please try again.', Colors.red);
      enteredPin = '';
      Future.delayed(Duration(seconds: 1), () {
        updateErrorMessage('', Colors.black);
      });
    }
  }

  _setPassCode() async {
    String? storedPasscode = enteredPin;
    await _secureStorage.write(key: 'passcode', value: storedPasscode);
    updateErrorMessage('Passcode Set', Colors.green.shade800);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainPage())); // Replace HomePage with your actual home page widget
      });
    });
  }

  _disable() async {
    await _secureStorage.write(key: 'passcode', value: '');
    updateErrorMessage('Passcode Disable', Colors.red);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainPage())); // Replace HomePage with your actual home page widget
      });
    });
  }

  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (enteredPin.length < 4) {
              enteredPin += number.toString();
              if (enteredPin.length == 4) {
                // Check the passcode when all 4 digits are entered
                if (widget.status == 'New') {
                  _setPassCode();
                } else if (widget.status == 'Disable') {
                  _disable();
                } else {
                  _checkPasscode();
                }
              }
            }
          });
        },
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  String errorMessage = ''; // Variable to store error message

  // Function to update the error message
  void updateErrorMessage(String message, Color color) {
    setState(() {
      errorMessage = message;
      errorMessageColor = color;
    });
  }

  Color errorMessageColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Passcode',
                  style: GoogleFonts.redHatDisplay(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              /// pin code area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      width: isPinVisible ? 50 : 16,
                      height: isPinVisible ? 50 : 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: index < enteredPin.length
                            ? isPinVisible
                                ? Colors.black
                                : Colors.black
                            : CupertinoColors.black.withOpacity(0.1),
                      ),
                      child: isPinVisible && index < enteredPin.length
                          ? Center(
                              child: Text(
                                enteredPin[index],
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),

              /// visiblity toggle button
              SizedBox(
                height: 35,
              ),
              // IconButton(
              //   onPressed: () {
              //     setState(() {
              //       isPinVisible = !isPinVisible;
              //     });
              //   },
              //   icon: Icon(
              //     isPinVisible ? Icons.visibility_off : Icons.visibility,
              //   ),
              // ),

              // SizedBox(height: isPinVisible ? 10.0 : 8.0),

              /// digits
              if(widget.status == 'Change')
              Text('Enter Current Passcode to Continue',style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w500,color: Colors.green.shade900),),
              if(widget.status == 'Disable')
              Text('Enter Current Passcode to Disable',style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w500,color: Colors.green.shade900),),
              if(widget.status == 'New')
              Text('Enter New Passcode',style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w500,color: Colors.green.shade900),),
              SizedBox(height: 25,),
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (index) => numButton(1 + 3 * i + index),
                    ).toList(),
                  ),
                ),

              /// 0 digit with back remove
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextButton(onPressed: null, child: SizedBox()),
                    numButton(0),
                    TextButton(
                      onPressed: () {
                        setState(
                          () {
                            if (enteredPin.isNotEmpty) {
                              enteredPin = enteredPin.substring(
                                  0, enteredPin.length - 1);
                            }
                          },
                        );
                      },
                      child: const Icon(
                        Icons.backspace,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              
              
              SizedBox(height: 10,),
              Text(
                errorMessage,
                style: GoogleFonts.poppins(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: errorMessageColor,
                  fontSize: 16,
                ),
              ),

              /// reset button
              // TextButton(
              //   onPressed: () {
              //     setState(() {
              //       enteredPin = '';
              //     });
              //   },
              //   child: const Text(
              //     'Reset',
              //     style: TextStyle(
              //       fontSize: 20,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
