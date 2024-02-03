import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:investfolio/HomePage/analysisChart.dart';
import 'package:investfolio/HomePage/dataInput.dart';
import 'package:investfolio/NavBar/detailsPage.dart';
import 'package:investfolio/NavBar/profilePage.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../InvestmentDetails/investment_details_page.dart';
import '../main.dart';
import '../test/test.dart';

extension ToUpperCaseAfterSpace on String {
  String toUpperCaseAfterSpace() {
    if (this == null || this.isEmpty) {
      return this;
    }

    List<String> words = this.split(' ');

    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    return words.join(' ');
  }
}

double calculateReturnPercentage(double totalInvestment, double roi) {
  return (roi / totalInvestment) * 100;
}

String generateInitials(String name) {
  List<String> nameParts =
      name.split(' ').where((part) => part.isNotEmpty).toList();
  String initials = '';

  if (nameParts.isNotEmpty) {
    for (int i = 0; i < nameParts.length; i++) {
      initials += nameParts[i][0];
    }
  }

  return initials.toUpperCase();
}

String getGreeting() {
  DateTime now = DateTime.now();
  int hour = now.hour;

  if (hour >= 6 && hour < 12) {
    return 'Good Morning';
  } else if (hour >= 12 && hour < 18) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // formattedmoney(double money) {
  //   return indianRupeeFormat.format(money);
  // }

  // String name = 'Mashud Talukdar';
  // late double totalInvestment = 200000;
  // late double roi = 30000;
  // late double returnPercentage =
  //     calculateReturnPercentage(totalInvestment, roi);

  // late var indianRupeeFormat =
  //     NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  // late var formattedTotalInvestment = indianRupeeFormat.format(totalInvestment);
  // late var formattedROI = indianRupeeFormat.format(roi);

  final List<Map<String, dynamic>> data = [];

  //Google Sign out
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //fetch user details
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String profilePictureUrl = '';
  late String displayName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final User? user = _auth.currentUser;
    print(user);

    if (user != null) {
      // Try to fetch the cached profile picture URL and name from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final cachedUrl = prefs.getString('profilePictureUrl') ?? '';
      final cachedName = prefs.getString('displayName') ?? '';

      // Fetch the user data from Firestore
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final fetchedUrl = userDoc['profilepicture'] ?? '';
        final fetchedName = userDoc['Name'] ?? '';
        print('Fetched Profile Picture URL: $fetchedUrl'); // Debug print
        print('Fetched Name: $fetchedName'); // Debug print

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

        setState(() {
          profilePictureUrl = fetchedUrl ?? ''; // Ensure it's not null
          displayName = fetchedName ?? '';
        });
      }
    }
  }

  Map<String, double> calculateTotalPortfolioData(
      List<Map<String, dynamic>> investmentData) {
    double totalInvestment = 0.0;
    double totalROI = 0.0;

    for (final investment in investmentData) {
      final investmentAmountStr = investment['investmentAmount'] ?? '0.0';
      final returnAmountG = investment['returnAmount'] ?? '0.0';
      final investmentAmountP = double.tryParse(investmentAmountStr) ?? 0.0;
      final returnAmountF = double.tryParse(returnAmountG) ?? 0.0;

      totalInvestment += investmentAmountP;
      totalROI += returnAmountF;
    }

    return {'totalInvestment': totalInvestment, 'totalROI': totalROI};
  }

  //fetch individual investment
  Future<List<Map<String, dynamic>>> fetchData2() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null) {
      return [];
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Investment')
        .doc('InvestmentData')
        .collection('Investments')
        .get();

    final data = snapshot.docs.map((doc) {
      final documentId = doc.id; // Get the document ID
      final documentData = doc.data(); // Get the document data
      return {
        'documentId': documentId,
        ...documentData, // Include the document data along with the document ID
      };
    }).toList();

    return data.cast<Map<String, dynamic>>();
  }

  Future onAddData(
      Map<String, dynamic> newData, BuildContext parentContext) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId == null) {
        return;
      }

      final DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('Investment')
          .doc('InvestmentData');

      DocumentSnapshot userDoc = await userRef.get();
      DateTime startingInvestmentDate = newData['StartingInvestmentDate'];
      String roiAmountStr = newData['returnAmount'] ?? '0.0';
      String investmentAmountStr = newData['investmentAmount'] ?? '0.0';

      double roiAmount = double.parse(roiAmountStr) ?? 0.0;
      double investmentAmount = double.parse(investmentAmountStr) ?? 0.0;

      newData['StartingInvestmentDate'] = startingInvestmentDate;
      DocumentReference newInvestmentRef =
          await userRef.collection('Investments').add(newData);

      List<Map<String, dynamic>> dataPoints = [];

      if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('dataPoints')) {
          dataPoints = List<Map<String, dynamic>>.from(userData['dataPoints']);
        }
      }

      DateTime currentDate = DateTime.now();
      int monthsDifference = currentDate.month - startingInvestmentDate.month;
      int yearsDifference = currentDate.year - startingInvestmentDate.year;
      int totalMonths = yearsDifference * 12 + monthsDifference;

      // Reset currentDate to the initial date
      currentDate = startingInvestmentDate;

      // Get the month when the investment is added
      int startingMonth = startingInvestmentDate.month;

      for (int i = 0; i <= totalMonths; i++) {
        String monthName = DateFormat('MMM').format(currentDate);
        String yearMonth = DateFormat('yyyy-MM').format(currentDate);
        double monthlyROI = (i == 0 && startingMonth == currentDate.month)
            ? 0.0 // Assign 0 return for the starting month
            : roiAmount / totalMonths; // Distribute the total return

        double monthlyInvestment = (i == 0)
            ? investmentAmount
            : 0.0; // Assign investmentAmount only for the starting month

        int existingMonthIndex =
            dataPoints.indexWhere((point) => point['yearMonth'] == yearMonth);

        if (existingMonthIndex >= 0) {
          // Update the existing data point
          Map<String, dynamic> existingPoint = dataPoints[existingMonthIndex];
          existingPoint['roiAmount'] += monthlyROI;

          // Ensure InvestmentAmount exists in the existing data point
          if (existingPoint.containsKey('InvestmentAmount')) {
            existingPoint['InvestmentAmount'] += monthlyInvestment;
          } else {
            existingPoint['InvestmentAmount'] = monthlyInvestment;
          }
        } else {
          // Create a new data point
          Map<String, dynamic> dataPoint = {
            'yearMonth': yearMonth,
            'month': monthName,
            'roiAmount': monthlyROI,
            'InvestmentAmount': monthlyInvestment,
          };
          dataPoints.add(dataPoint);
        }

        print(
            'Month: $monthName, ROI: $monthlyROI, Investment: $monthlyInvestment, DataPoints: $dataPoints');

        // Update currentDate with proper handling for month increment
        currentDate = DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      }

      // Update Firestore document after constructing the entire dataPoints list
      await userRef.set({
        'dataPoints': dataPoints,
      });

      List<Map<String, dynamic>> dataPoints2 = [];
      int totalMonths2 = yearsDifference * 12 + monthsDifference;

      // Create a new instance of currentDate2 for the second loop
      DateTime currentDate2 = DateTime.now();

      for (int i = 0; i <= totalMonths2; i++) {
        String monthName2 = DateFormat('MMM').format(currentDate2);
        String yearMonth2 = DateFormat('yyyy-MM').format(currentDate2);
        double monthlyROI2 =
            (i == totalMonths2 && startingMonth == currentDate2.month)
                ? 0.0 // Assign 0 return for the starting month
                : roiAmount / totalMonths2; // Distribute the total return

        double monthlyInvestment2 = (i == totalMonths2)
            ? investmentAmount
            : 0.0; // Assign investmentAmount only for the starting month

        Map<String, dynamic> dataPoint2 = {
          'yearMonth': yearMonth2,
          'month': monthName2,
          'roiAmount': monthlyROI2,
          'InvestmentAmount': monthlyInvestment2,
        };
        dataPoints2.add(dataPoint2);

        print(
            'Month: $monthName2, ROI: $monthlyROI2, Investment: $monthlyInvestment2, DataPoints2: $dataPoints2');

        // Update currentDate2 with proper handling for month decrement
        if (currentDate2.month > 1) {
          currentDate2 = DateTime(
            currentDate2.year,
            currentDate2.month - 1,
            currentDate2.day,
          );
        } else {
          currentDate2 = DateTime(
            currentDate2.year - 1,
            12, // December
            currentDate2.day,
          );
        }
      }

      // Update Firestore document after constructing the entire dataPoints2 list
      await newInvestmentRef.update({
        'dataPoints': dataPoints2,
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
          ModalRoute.withName("/Home"));
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future _restartApp() async {
    // fetchData2();
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);

    return;
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      color: const Color.fromARGB(255, 40, 85, 42),
      backgroundColor: Colors.white,
      height: MediaQuery.of(context).size.height / 4,
      animSpeedFactor: 2,
      // showChildOpacityTransition: true,
      // showChildOpacityTransition: true,
      // springAnimationDurationInMilliseconds: 2,
      onRefresh: () {
        return _restartApp();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('img/bg2.jpg'),
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
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 25, left: 8, right: 8),
                          child: Row(
                            children: [
                              // Icon(
                              //   Icons.no_accounts,
                              //   size: 45,
                              // ),
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.5),
                                radius: 23,
                                backgroundImage: (profilePictureUrl.isNotEmpty)
                                    ? NetworkImage(profilePictureUrl)
                                        as ImageProvider<Object>?
                                    : null, // Don't specify any image here
                                child: (profilePictureUrl.isEmpty)
                                    ? Text(
                                        generateInitials(displayName),
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            letterSpacing: 1),
                                      )
                                    : null, // Show initials only if there's no image
                              ),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${getGreeting()},',
                                    style: GoogleFonts.redHatDisplay(
                                        letterSpacing: 0.5,
                                        // fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    displayName,
                                    style: GoogleFonts.redHatDisplay(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchData2(), // Fetch portfolio investment data
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Color(0xFF3A5F0B),
                          ));
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final investmentData = snapshot.data ?? [];
                          final totalData =
                              calculateTotalPortfolioData(investmentData);
                          final formattedTotalInvestment =
                              NumberFormat.currency(
                            locale: 'en_IN',
                            symbol: '₹',
                          ).format(totalData['totalInvestment']);
                          final formattedTotalROI = NumberFormat.currency(
                            locale: 'en_IN',
                            symbol: '₹',
                          ).format(totalData['totalROI']);

                          final returnPercentage = (totalData['totalROI']! /
                                  totalData['totalInvestment']!) *
                              100;

                          return Container(
                            height: MediaQuery.of(context).size.height / 4.2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total Investment',
                                  style: GoogleFonts.redHatDisplay(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  formattedTotalInvestment,
                                  style: GoogleFonts.redHatDisplay(
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 23,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ROI : $formattedTotalROI',
                                      style: GoogleFonts.redHatDisplay(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '+${returnPercentage.toStringAsFixed(2)} %',
                                      style: GoogleFonts.redHatDisplay(
                                        color: const Color.fromARGB(
                                            255, 28, 83, 30),
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      // height: MediaQuery.of(context).size.height / 4,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Portfolio',
                                  style: GoogleFonts.redHatDisplay(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 1.5),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.only(right: 8.0),
                                //   child: Text(
                                //     'View All',
                                //     style: TextStyle(
                                //         fontSize: 15,
                                //         fontWeight: FontWeight.w500,
                                //         color: Color(0xFF3A5F0B)),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchData2(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                          color: Color(0xFF3A5F0B))),
                                ));
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final data = snapshot.data ?? [];
                                return SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.length +
                                        1, // +1 for the "Add Data" button
                                    itemBuilder: (context, index) {
                                      if (index == data.length) {
                                        // Display the "Add Data" button as the last item
                                        return Card(
                                          margin: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              BuildContext parentContext =
                                                  context;
                                              showDialog(
                                                context: parentContext,
                                                builder: (dialogContext) {
                                                  return DataInputDialog(
                                                    onAddData: (newData) async {
                                                      await onAddData(newData,
                                                          parentContext);
                                                      // Navigator.of(dialogContext)
                                                      //     .pop(); // Close the dialog
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Color(0xFF3A5F0B)),
                                              width: 140,
                                              child: Center(
                                                child: Text(
                                                  'Add\nInvestment',
                                                  softWrap: true,
                                                  style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        final investment = data[index];
                                        print(data);
                                        final investmentType =
                                            investment['investmentType'];
                                        final investmentName =
                                            investment['investmentName'];
                                        final investmentAmount =
                                            investment['investmentAmount'];
                                        final investmentAmountStr =
                                            investment['investmentAmount'] ??
                                                '0.0';
                                        final investmentAmountP =
                                            double.tryParse(
                                                    investmentAmountStr) ??
                                                0.0;
                                        final formattedInvestmentAmount =
                                            NumberFormat.currency(
                                                    locale: 'en_IN',
                                                    symbol: '₹')
                                                .format(investmentAmountP);

                                        final returnAmount =
                                            investment['returnAmount'];
                                        final returnAmountG =
                                            investment['returnAmount'] ?? '0.0';
                                        final returnAmountF =
                                            double.tryParse(returnAmountG) ??
                                                0.0;
                                        final formattedReturnAmount =
                                            NumberFormat.currency(
                                                    locale: 'en_IN',
                                                    symbol: '₹')
                                                .format(returnAmountF);

                                        final returnPercentage = returnAmountF /
                                            investmentAmountP *
                                            100;

                                        return GestureDetector(
                                          onTap: () {
                                            final investment = data[index];
                                            final documentId = investment[
                                                'documentId']; // Replace with your actual document ID key
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    InvestmentDetailPage(
                                                        documentId: documentId),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            color:
                                                Colors.green.withOpacity(0.5),
                                            margin: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 200.0,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    investmentType
                                                        .toString()
                                                        .toUpperCase(),
                                                    softWrap: true,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    investmentName
                                                        .toString()
                                                        .toUpperCaseAfterSpace(),
                                                    softWrap: true,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const SizedBox(height: 8.0),
                                                  Text(
                                                      'Invested: $formattedInvestmentAmount'),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          'ROI: $formattedReturnAmount'),
                                                      Text(
                                                        ' +${returnPercentage.toStringAsFixed(0)}%',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Container(
                        // color: Colors.red,
                        // height: MediaQuery.of(context).size.height / 3,
                        // width: double.infinity,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analysis',
                              style: GoogleFonts.redHatDisplay(
                                  letterSpacing: 1.5,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 35,
                            ),
                            Center(
                                child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                    child: Text(
                                  'Return On Investment',
                                  style: GoogleFonts.poppins(),
                                )),
                                AnalysisPart(),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchData2(),
              builder: (context, snapshot) {
                return Positioned.fill(
                  child: Visibility(
                    visible:
                        snapshot.connectionState == ConnectionState.waiting,
                    child: FutureBuilder(
                      future: Future.delayed(
                          Duration(seconds: 1)), // Add an extra second delay
                      builder: (context, delaySnapshot) {
                        if (delaySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Display CircularProgressIndicator during the delay
                          return Container(
                            color: Colors.white,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF3A5F0B)),
                            ),
                          );
                        } else {
                          // Data is loaded, so hide CircularProgressIndicator
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
