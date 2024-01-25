import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:investfolio/NavBar/AppSetting/lock_screen_passcode.dart';
import 'package:investfolio/NavBar/mainPage.dart';

class LockScreenCheck extends StatefulWidget {
  const LockScreenCheck({Key? key}) : super(key: key);

  @override
  State<LockScreenCheck> createState() => _LockScreenCheckState();
}

class _LockScreenCheckState extends State<LockScreenCheck> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  _loadPasscode() async {
    String? storedPasscode = await _secureStorage.read(key: 'passcode');
    
    // Check if passcode is set for the first time
    if (storedPasscode == null || storedPasscode == '') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PinCodeWidget()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // You can show a loading indicator or any other UI while checking passcode
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.green.shade900,),
      ),
    );
  }
}
