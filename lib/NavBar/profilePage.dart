import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:investfolio/NavBar/AppSetting/app_setting_menu.dart';
import 'package:investfolio/NavBar/AppSetting/lock_screen_passcode.dart';
import 'package:investfolio/NavBar/AppSetting/set_passcode.dart';
import 'package:investfolio/NavBar/ProfileSection/aboutus_page.dart';
import 'package:investfolio/NavBar/ProfileSection/edit_profile.dart';
import 'package:investfolio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Basic/forget_password_page.dart';
import '../HomePage/home_page.dart';
import 'ProfileSection/help_page.dart';
import 'ProfileSection/investment_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserProfile();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //fetch user details
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String profilePictureUrl = '';
  late String displayName = '';
  late String email = '';

  Future<void> _fetchUserProfile() async {
    final User? user = _auth.currentUser;
    print(user);

    if (user != null) {
      // Try to fetch the cached profile picture URL, name, and email from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final cachedUrl = prefs.getString('profilePictureUrl') ?? '';
      final cachedName = prefs.getString('displayName') ?? '';
      final cachedEmail = prefs.getString('email') ?? '';

      // Fetch the user data from Firestore
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final fetchedUrl = userDoc['profilepicture'] ?? '';
        final fetchedName = userDoc['Name'] ?? '';
        final fetchedEmail = userDoc['email'] ?? '';
        print('Fetched Profile Picture URL: $fetchedUrl'); // Debug print
        print('Fetched Name: $fetchedName'); // Debug print
        print('Fetched Email: $fetchedEmail'); // Debug print

        // Check if the cached URL matches the fetched URL
        if (cachedUrl != fetchedUrl) {
          // Cache the fetched URL locally
          prefs.setString('profilePictureUrl', fetchedUrl);
        }

        // Check if the cached name matches the fetched name
        if (cachedName != fetchedName) {
          // Cache the fetched name locally
          prefs.setString('displayName', fetchedName);
        }

        // Check if the cached email matches the fetched email
        if (cachedEmail != fetchedEmail) {
          // Cache the fetched email locally
          prefs.setString('email', fetchedEmail);
        }

        setState(() {
          profilePictureUrl = fetchedUrl ?? ''; // Ensure it's not null
          displayName = fetchedName ?? '';
          email = fetchedEmail ?? '';
        });
      }
    }
  }

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.redHatDisplay(
              letterSpacing: 1.2, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.5),
              const Color.fromARGB(255, 195, 214, 214).withOpacity(0.2),
            ],
          ),
        ),
      ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 42,
                      backgroundImage: (profilePictureUrl.isNotEmpty)
                          ? NetworkImage(profilePictureUrl)
                              as ImageProvider<Object>?
                          : null, // Don't specify any image here
                      child: (profilePictureUrl.isEmpty)
                          ? Text(
                              generateInitials(displayName),
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  color: Colors.white,
                                  letterSpacing: 1),
                            )
                          : null, // Show initials only if there's no image
                    ),
                    const SizedBox(height: 13),
                    Text(
                      displayName,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      email,
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.7),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Divider(
                  color: Colors.grey,
                  height: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildOptionTile('Edit Profile', Icons.settings, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      );
                    }),
                    _buildOptionTile('App Setting', Icons.lock, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AppSettingMenuPage(),
                        ),
                      );
                    }),
                    _buildOptionTile('Edit Investment', Icons.tune, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MyListViewPage(),
                        ),
                      );
                    }),
                    _buildOptionTile('Help & Support', Icons.phone, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      );
                    }),
                    _buildOptionTile('About Us', Icons.help, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Divider(
                  color: Colors.grey,
                  height: 2,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _secureStorage.write(key: 'passcode', value: '');
                    await googleSignIn.signOut(); // Sign out from Google
                    await _auth.signOut(); // Sign out from Firebase
          
                    FirebaseAuth.instance
                        .signOut()
                        .then((value) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyApp()), // Your new screen
                              (Route<dynamic> route) =>
                                  false, // Remove all previous routes
                            ));
          
                    // Optionally, you can also clear the user's information from Firestore if needed
                    // await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid).delete();
          
                    // Navigate back to the sign-up page or any other desired screen
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUpPage()));
                  } catch (error) {
                    print(error.toString());
                  }
                }, // Handle log out action
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Log out',
                      style: GoogleFonts.poppins(
                          letterSpacing: 1, color: Colors.black),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.logout,
                      color: Colors.black,
                      size: 18,
                    )
                  ],
                ),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerRight,
                ),
              ),
              
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
