import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:investfolio/NavBar/mainPage.dart';
import 'package:investfolio/NavBar/profilePage.dart';

import '../../HomePage/home_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late User? _user;
  late String _name = 'User';
  late String _email = '';
  late String _image = '';
  File? _imageFile;
  bool _isLoadingImage = false;

  @override
  void initState() {
    _fetchUserData();
    // TODO: implement initState
    super.initState();
  }

  Future _fetchUserData() async {
    var image;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          image = userData['profilepicture'].toString();
          if (image == 'null') {
            image = '';
          }

          setState(() {
            _name = userData['Name'];
            _email = userData['email'].toString();
            _image = image;
          });
        }
        print(_image);
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  // Future _uploadImage() async {
  //   await _pickImage();
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null && _imageFile != null) {
  //     try {
  //       setState(() {
  //         _isLoadingImage = true;
  //       });

  //       final storageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('Profile Picture')
  //           .child(user.uid)
  //           .child('image.jpg');
  //       final uploadTask = storageRef.putFile(_imageFile!);
  //       final storageSnapshot = await uploadTask.whenComplete(() => null);
  //       final downloadUrl = await storageSnapshot.ref.getDownloadURL();

  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .update({'profilepicture': downloadUrl});

  //       setState(() {
  //         _fetchUserData();
  //         _isLoadingImage = false;
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text(
  //           'Profile picture updated',
  //           textAlign: TextAlign.center,
  //         )),
  //       );
  //     } catch (error) {
  //       print('Error uploading image: $error');
  //       setState(() {
  //         _isLoadingImage = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error uploading image')),
  //       );
  //     }
  //   }
  // }
  Future<void> _uploadImage() async {
    await _pickImage();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _imageFile != null) {
      try {
        // Show circular progress indicator
        showDialog(
          context: context,
          barrierDismissible: false, // To prevent tapping outside to dismiss
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('Profile Picture')
            .child(user.uid)
            .child('image.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        final storageSnapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await storageSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profilepicture': downloadUrl});

        // Hide circular progress indicator
        Navigator.pop(context);

        // Navigate to ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } catch (error) {
        print('Error uploading image: $error');
        // Hide circular progress indicator
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image')),
        );
      }
    }
  }

  Future _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  // void _saveEditedName() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .update({'Name': _name});

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Name updated successfully'),
  //         ),
  //       );
  //     } catch (error) {
  //       print('Error updating name: $error');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error updating name'),
  //         ),
  //       );
  //     }
  //   }
  // }
  Future<void> _saveEditedName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'Name': _name});

        // No need for the delay here

        Navigator.pop(context);

        // Navigate to ProfilePage after the update is complete
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Name updated successfully',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } catch (error) {
        print('Error updating name: $error');

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating name'),
          ),
        );
      }
    }
  }

  void _openEditNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextFormField(
            initialValue: _name,
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'New Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveEditedName();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _openEditEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Email'),
          content: TextFormField(
            onChanged: (value) {
              _email = value;
            },
            decoration: InputDecoration(
              labelText: 'New Email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Save the edited name and close the dialog
                _saveEditedEmail();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEditedEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Show circular progress indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Update email in Firebase Authentication
        await user.updateEmail(_email);

        // Update email in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'email': _email});

        // Hide circular progress indicator
        Navigator.pop(context);

        // Navigate to ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Email updated successfully. Please check your email for verification.'),
          ),
        );
      } on FirebaseAuthException catch (error) {
        print('Error updating email: ${error.message}');
        // Hide circular progress indicator after the delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating email: ${error.message}'),
          ),
        );
      } catch (error) {
        print('Unexpected error: $error');
        // Hide circular progress indicator after the delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error occurred'),
          ),
        );
      }
    }
  }

  //For Password
  void _openEditPasswordDialog() {
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';
    bool passwordMismatch = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Password
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) {
                      currentPassword = value;
                      if (passwordMismatch &&
                          currentPassword.length == confirmPassword.length) {
                        setState(() {
                          passwordMismatch = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                    ),
                  ),
                  SizedBox(height: 10),

                  // New Password
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) {
                      newPassword = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'New Password',
                    ),
                  ),
                  SizedBox(height: 10),

                  // Confirm Password
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) {
                      confirmPassword = value;
                      if (currentPassword.length == confirmPassword.length &&
                          currentPassword != confirmPassword) {
                        setState(() {
                          passwordMismatch = true;
                        });
                      } else {
                        setState(() {
                          passwordMismatch = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      errorText:
                          passwordMismatch ? 'Passwords do not match' : null,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate the form before saving
                Navigator.pop(context);
                if (!passwordMismatch) {
                  // Save the edited password and close the dialog
                  _changePassword(currentPassword, newPassword);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Show circular progress indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Reauthenticate user before changing password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password in Firebase Authentication
        await user.updatePassword(newPassword);

        // Hide circular progress indicator
        Navigator.pop(context);

        // Navigate to ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully'),
          ),
        );
      } catch (error) {
        print('Error changing password: $error');
        String errorMessage = 'Error changing password';

        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'wrong-password':
              errorMessage = 'Current password is incorrect';
              break;
            case 'requires-recent-login':
              errorMessage =
                  'This operation is sensitive and requires recent authentication. Please log in again before changing the password.';
              break;
            default:
              errorMessage = 'An error occurred while changing the password';
          }
        }

        // Hide circular progress indicator after the delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 17, 90, 22),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
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
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 45,
                          backgroundImage: (_image.isNotEmpty)
                              ? NetworkImage(_image) as ImageProvider<Object>?
                              : null, // Don't specify any image here
                          child: (_image.isEmpty)
                              ? Text(
                                  generateInitials(_name),
                                  style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      color: Colors.white,
                                      letterSpacing: 1),
                                )
                              : null, // Show initials only if there's no image
                        ),
                        const SizedBox(height: 11),
                        Text(
                          _name,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.7),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          _email,
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
                      height: MediaQuery.of(context).size.height / 28,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildOptionTile('Edit Name', Icons.edit, () {
                          _openEditNameDialog();
                        }),
                        _buildOptionTile('Change Email', Icons.email, () {
                          _openEditEmailDialog();
                        }),
                        _buildOptionTile('Change Password', Icons.lock, () {
                          _openEditPasswordDialog();
                        }),
                        _buildOptionTile('Change Profile Picture', Icons.image,
                            () {
                          _uploadImage();
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, Function() onTap) {
    return ListTile(
      title: Text(title),
      trailing: Icon(
        icon,
        size: 18,
        // color: Colors.green.shade900,
      ),
      onTap: onTap,
    );
  }
}
