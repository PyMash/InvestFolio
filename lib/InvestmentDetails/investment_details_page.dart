import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:investfolio/InvestmentDetails/analysischart_investment.dart';
import 'package:investfolio/InvestmentDetails/edit_investment_page.dart';

class InvestmentDetailPage extends StatefulWidget {
  final String documentId;

  InvestmentDetailPage({required this.documentId});

  @override
  State<InvestmentDetailPage> createState() => _InvestmentDetailPageState();
}

class _InvestmentDetailPageState extends State<InvestmentDetailPage> {
  Future<void> deleteInvestmentData() async {
    try {
      // Show circular progress indicator to indicate deletion in progress
      showDeleteProgressDialog();

      // Fetch existing data points from the first location
      final firstLocationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Investment')
          .doc('InvestmentData')
          .collection('Investments')
          .doc(widget.documentId)
          .get();

      List<Map<String, dynamic>> existingFirstLocationDataPoints =
          List<Map<String, dynamic>>.from(
              firstLocationSnapshot.data()?['dataPoints'] ?? []);

      // If there are no data points, display an error or handle it as needed
      if (existingFirstLocationDataPoints.isEmpty) {
        print('No data found. Deletion is not possible.');
        // You may want to show a message to the user, set a state, or use a Snackbar
        return;
      }

      // Fetch existing data points from the second location
      final secondLocationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Investment')
          .doc('InvestmentData') // Adjust this path to your second location
          .get();

      List<Map<String, dynamic>> existingSecondLocationDataPoints =
          List<Map<String, dynamic>>.from(
              secondLocationSnapshot.data()?['dataPoints'] ?? []);

      // Iterate through data points in the first location
      for (int i = 0; i < existingFirstLocationDataPoints.length; i++) {
        String yearMonth = existingFirstLocationDataPoints[i]['yearMonth'];

        // Find the corresponding entry in the second location
        for (int j = 0; j < existingSecondLocationDataPoints.length; j++) {
          if (existingSecondLocationDataPoints[j]['yearMonth'] == yearMonth) {
            // Subtract roiAmount and InvestmentAmount
            existingSecondLocationDataPoints[j]['roiAmount'] -=
                existingFirstLocationDataPoints[i]['roiAmount'];
            existingSecondLocationDataPoints[j]['InvestmentAmount'] -=
                existingFirstLocationDataPoints[i]['InvestmentAmount'];
            break;
          }
        }
      }

      // Update Firestore document at the second location
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Investment')
          .doc('InvestmentData') // Adjust this path to your second location
          .update({
        'dataPoints': existingSecondLocationDataPoints,
      });

      // Clear data points in the first location
      existingFirstLocationDataPoints.clear();

      // Update Firestore document at the first location
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Investment')
          .doc('InvestmentData')
          .collection('Investments')
          .doc(widget.documentId)
          .delete();

      // Display success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Data deleted successfully.',
            style: GoogleFonts.poppins(letterSpacing: 1, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Close the popup or navigate to another page as needed
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      // Handle Firestore errors here
      print('Error deleting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while deleting. Please try again.',
            style: GoogleFonts.poppins(letterSpacing: 1, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
      // You may want to show a message to the user, set a state, or use a Snackbar
    } finally {
      // Hide the circular progress indicator after completion (whether success or error)
      hideDeleteProgressDialog();
    }
  }

// Show circular progress indicator
  void showDeleteProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 40, 85, 42),
          ),
        );
      },
    );
  }

// Hide circular progress indicator
  void hideDeleteProgressDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  List<DataPoint> dataPoints = [];
  bool isLoadingMR = true;
  Future<void> fetchMonthlyReturn() async {
    String? userUid = await getCurrentUserUid();

    if (userUid != null) {
      final collectionReference = FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('Investment')
          .doc('InvestmentData')
          .collection('Investments')
          .doc(widget.documentId);

      try {
        final documentSnapshot = await collectionReference.get();
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final fetchedDataPoints =
              (data['dataPoints'] as List<dynamic>?) ?? [];
          dataPoints = fetchedDataPoints.map((dataPoint) {
            final yearMonth = dataPoint['yearMonth'] as String;
            final parts = yearMonth.split('-');
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            return DataPoint(
              month,
              dataPoint['roiAmount'].toDouble(),
              dataPoint['InvestmentAmount'].toDouble(),
              year,
            );
          }).toList();

          // Sort the dataPoints list by year and month
          dataPoints.sort((a, b) {
            if (a.year == b.year) {
              return a.month.compareTo(b.month);
            } else {
              return a.year - b.year;
            }
          });

          // Keep only the last 6 entries

          // No need for setState as it's handled by FutureBuilder
        } else {
          dataPoints = [];
          // No need for setState as it's handled by FutureBuilder
        }
      } catch (e) {
        print("Error fetching investment data: $e");
        dataPoints = [];
        // No need for setState as it's handled by FutureBuilder
      }
    }
  }

  Future<String?> getCurrentUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  int getMonthsWithPositiveROI(List<DataPoint> dataPoints) {
    Set<String> uniqueYearMonths = Set<String>();

    for (DataPoint dataPoint in dataPoints) {
      if (dataPoint.roiAmount > 0) {
        String yearMonth = "${dataPoint.year}-${dataPoint.month}";
        uniqueYearMonths.add(yearMonth);
      }
    }

    return uniqueYearMonths.length;
  }

  double getAvgMonthlyReturn(List<DataPoint> dataPoints) {
    if (dataPoints.length < 2) {
      return 0.0; // Return 0 if there are not enough data points
    }

    // Sort the dataPoints list by year and month
    dataPoints.sort((a, b) {
      if (a.year == b.year) {
        return a.month.compareTo(b.month);
      } else {
        return a.year - b.year;
      }
    });

    // Calculate the average monthly return based on the last two months
    double avgMonthlyReturn = (dataPoints.last.roiAmount +
            dataPoints[dataPoints.length - 2].roiAmount) /
        2;

    return avgMonthlyReturn;
  }

  late double investedAmount;
  late double returnAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Investment Details',
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
          ),
          SingleChildScrollView(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('Investment')
                  .doc('InvestmentData')
                  .collection('Investments')
                  .doc(widget.documentId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('Data not found'),
                  );
                } else {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final investmentType = data['investmentType'];
                  final investmentName = data['investmentName'];
                  final investedAmountStr = data['investmentAmount'];
                  final returnAmountStr = data['returnAmount'];

                  investedAmount = double.tryParse(investedAmountStr) ?? 0.0;
                  returnAmount = double.tryParse(returnAmountStr) ?? 0.0;
                  final profit = returnAmount > investedAmount
                      ? returnAmount - investedAmount
                      : 0.0;
                  int estimatedMonthsToProfitF(
                      double totalInvestment,
                      double alreadyReceivedReturn,
                      List<DataPoint> dataPoints) {
                    if (dataPoints.length < 2) {
                      // Not enough data points to calculate
                      return -1; // Return a special value to indicate invalid input
                    }

                    // Sort the dataPoints list by year and month
                    dataPoints.sort((a, b) {
                      if (a.year == b.year) {
                        return a.month.compareTo(b.month);
                      } else {
                        return a.year - b.year;
                      }
                    });

                    double avgMonthlyReturn = (dataPoints.last.roiAmount +
                            dataPoints[dataPoints.length - 2].roiAmount) /
                        2;

                    if (avgMonthlyReturn <= 0) {
                      // Avoid division by zero or negative values
                      return -1; // Return a special value to indicate invalid input
                    }

                    double cumulativeROI = alreadyReceivedReturn;
                    int months = 0;

                    while (cumulativeROI < totalInvestment) {
                      cumulativeROI += avgMonthlyReturn;
                      months++;
                    }

                    return months;
                  }

                  return SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            '${investmentType.toString().toUpperCase()}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            '${investmentName.toString().toUpperCase()}',
                            style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Invested : ' +
                              NumberFormat.currency(
                                locale: 'en_IN',
                                symbol: '₹ ',
                              ).format(investedAmount ?? 0),
                          style: GoogleFonts.redHatDisplay(
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Return : ' +
                              NumberFormat.currency(
                                locale: 'en_IN',
                                symbol: '₹ ',
                              ).format(returnAmount ?? 0),
                          style: GoogleFonts.redHatDisplay(
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                              fontSize: 15),
                        ),
                        if (returnAmount >
                            investedAmount) // Only show profit when return is greater
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Profit: ₹${profit.toStringAsFixed(2)}',
                              style: GoogleFonts.redHatDisplay(
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                          ),

                        SizedBox(
                          height: 5,
                        ),
                        FutureBuilder<void>(
                          future: fetchMonthlyReturn(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              double avgMonthlyReturn =
                                  getAvgMonthlyReturn(dataPoints);
                              int estimatedMonthsToProfit =
                                  estimatedMonthsToProfitF(
                                investedAmount,
                                returnAmount,
                                dataPoints,
                              );

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Avg Monthly Return : ',
                                        style: GoogleFonts.redHatDisplay(
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15),
                                      ),
                                      Text(
                                        // '₹ ${avgMonthlyReturn.toStringAsFixed(2)}',
                                        NumberFormat.currency(
                                          locale: 'en_IN',
                                          symbol: '₹ ',
                                        ).format(avgMonthlyReturn ?? 0),
                                        style: GoogleFonts.redHatDisplay(
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (returnAmount < investedAmount &&
                                      (estimatedMonthsToProfit > 0))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        ' Estimate profit within $estimatedMonthsToProfit months',
                                        style: GoogleFonts.redHatDisplay(
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      ),
                                    ),
                                ],
                              );
                            }
                          },
                        ),
                        AspectRatio(
                          aspectRatio:
                              1.8, // Adjust the aspect ratio to control pie chart size
                          child: PieChart(
                            PieChartData(
                              sections: [
                                if (returnAmount < investedAmount ||
                                    returnAmount ==
                                        investedAmount) // Show only when return is greater
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: returnAmount,
                                    showTitle: false,
                                  ),
                                if (returnAmount < investedAmount)
                                  PieChartSectionData(
                                    color: Colors.blue,
                                    value: investedAmount - returnAmount,
                                    showTitle: false,
                                  ),
                                if (returnAmount > investedAmount)
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: returnAmount - profit,
                                    showTitle: false,
                                  ),
                                if (returnAmount >
                                    investedAmount) // Only show profit when return is greater
                                  PieChartSectionData(
                                    color: Colors.amber,
                                    value: profit,
                                    showTitle: false,
                                  ),
                              ],
                              centerSpaceRadius:
                                  40, // Adjust the center space radius
                              sectionsSpace: 1,
                            ),
                          ),
                        ),
                        // Add spacing between pie chart and legend
                        LegendWidget(
                            investedAmount: investedAmount,
                            returnAmount: returnAmount,
                            profit: profit),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ChartAnalysisIndividual(
                              documentId: widget.documentId),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        LegendWidget2(
                          investedAmount: investedAmount,
                          returnAmount: returnAmount,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16, // Adjust the bottom margin as needed
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 28, 68, 30),
                ),
                onPressed: () {
                  print('$investedAmount,$returnAmount');
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          EditInvestmentPopup(
                        initialInvestmentAmount: investedAmount,
                        initialReturnAmount: returnAmount,
                        documentId: widget.documentId,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return child;
                      },
                      transitionDuration: Duration(
                          seconds:
                              1), // Set the duration to 0 seconds for no animation
                    ),
                  );
                },
                child: Text(
                  'Edit Investment',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegendWidget extends StatelessWidget {
  final double investedAmount;
  final double returnAmount;
  final double profit;

  LegendWidget(
      {required this.investedAmount,
      required this.returnAmount,
      required this.profit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IndicatorWidget(
          color: Colors.green,
          label: 'Return',
        ),
        SizedBox(width: 16),
        IndicatorWidget(
          color: Colors.blue,
          label: 'Investment',
        ), // Only show profit in the legend when return is greater
        SizedBox(width: 16),
        IndicatorWidget(
          color: Colors.amber,
          label: 'Profit',
        ),
      ],
    );
  }
}

class LegendWidget2 extends StatelessWidget {
  final double investedAmount;
  final double returnAmount;

  LegendWidget2({
    required this.investedAmount,
    required this.returnAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IndicatorWidget2(
          color: const Color.fromARGB(255, 25, 80, 26),
          label: 'Return',
        ),
        SizedBox(width: 16),
        IndicatorWidget2(
          color: Colors.orange,
          label: 'Investment',
        ), // Only show profit in the legend when return is greater
      ],
    );
  }
}

class IndicatorWidget extends StatelessWidget {
  final Color color;
  final String label;

  IndicatorWidget({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class IndicatorWidget2 extends StatelessWidget {
  final Color color;
  final String label;

  IndicatorWidget2({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
