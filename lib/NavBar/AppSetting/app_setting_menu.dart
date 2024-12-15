import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investfolio/NavBar/AppSetting/set_passcode.dart';

class AppSettingMenuPage extends StatefulWidget {
  const AppSettingMenuPage({super.key});

  @override
  State<AppSettingMenuPage> createState() => _AppSettingMenuPageState();
}

class _AppSettingMenuPageState extends State<AppSettingMenuPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPasscode();
  }

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String EnableStatus = '';
  _loadPasscode() async {
    String? storedPasscode = await _secureStorage.read(key: 'passcode');
    // Check if passcode is set for the first time
    if (storedPasscode == null || storedPasscode == '') {
      // Set a default passcode (you can customize this logic)
      // storedPasscode = '1234';
      // await _secureStorage.write(key: 'passcode', value: storedPasscode);
      setState(() {
        EnableStatus = 'Disable';
      });
    } else {
      setState(() {
        EnableStatus = 'Enable';
      });
    }
  }

  bool isPasscodeSectionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'App Setting',
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 18, letterSpacing: 1.5),
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // Replace yourColor with the desired color
          ),
        ),
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
            Center(
                        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Toggle the value of isPasscodeSectionExpanded
                    setState(() {
                      isPasscodeSectionExpanded = !isPasscodeSectionExpanded;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'App Passcode',
                            style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              EnableStatus,
                              style: GoogleFonts.poppins(
                                  letterSpacing: 1, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Check isPasscodeSectionExpanded and EnableStatus when rendering the passcode section
                if (isPasscodeSectionExpanded && EnableStatus == 'Disable') ...[
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.keyboard_arrow_down_rounded),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SetPasscodePage(status: 'New'),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Enable Passcode',style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w500),),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isPasscodeSectionExpanded && EnableStatus == 'Enable') ...[
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.keyboard_double_arrow_down_rounded),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SetPasscodePage(status: 'Change'),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Change Passcode',style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w500),),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.keyboard_arrow_down_rounded),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SetPasscodePage(status: 'Disable'),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Disable Passcode',style: GoogleFonts.poppins(letterSpacing: 1,fontWeight: FontWeight.w500),),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
                        ),
                      ),
          
        ],
      ),
    );
  }
}
