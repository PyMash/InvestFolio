import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:investfolio/NavBar/AppSetting/reset_passcode.dart';
import 'package:investfolio/NavBar/mainPage.dart';

class PinCodeWidget extends StatefulWidget {
  const PinCodeWidget({Key? key}) : super(key: key);

  @override
  State<PinCodeWidget> createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget> {
  int wrong_passcode_counter = 0;
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
                builder: (context) =>
                    MainPage())); // Replace HomePage with your actual home page widget
      });
    } else {
      // Wrong Passcode, update the error message
      updateErrorMessage('Wrong Passcode, Please try again.');
      wrong_passcode_counter += 1 ;
      enteredPin = '';
      Future.delayed(Duration(seconds: 2), () {
        updateErrorMessage('');
      });
    }
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
                _checkPasscode();
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
  void updateErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent,),
      // backgroundColor: Colors.white,
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
          child: SafeArea(
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
                        letterSpacing: 1
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
                    height: 25,
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
                  Text(
                    'Enter Passcode to Continue',
                    style: GoogleFonts.poppins(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade900),
                  ),
                  SizedBox(
                    height: 20,
                  ),
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
                    height: 40,
                  ),
                  if(wrong_passcode_counter >1)
                  Column(
                    children: [
                                  
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ResetPasscode(),
                                              ),
                                            );
                    },
                    child: Text(
                      'Forget Passcode ?',
                      style: GoogleFonts.poppins(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.red),
                    ),
                  ),
                  if(wrong_passcode_counter >1)
                  SizedBox(height: 10,),
                    ],
                  ),             
                  Text(
                    errorMessage,
                    style: GoogleFonts.poppins(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
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
        ),
          
        ],
      ),
    );
  }
}
