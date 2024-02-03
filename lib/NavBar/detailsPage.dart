import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:investfolio/NavBar/nav_chart.dart';

class DataPoint {
  final int month;
  final double roiAmount;
  final double investmentAmount;
  final int year;

  DataPoint(this.month, this.roiAmount, this.investmentAmount, this.year);
}

class DetailsNavPage extends StatefulWidget {
  const DetailsNavPage({super.key});

  @override
  State<DetailsNavPage> createState() => _DetailsNavPageState();
}

class _DetailsNavPageState extends State<DetailsNavPage> {
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

  //fetch Montly return
  List<DataPoint> dataPoints = [];
  bool isLoadingMR = true;
  Future<void> fetchMonthlyReturn() async {
    String? userUid = await getCurrentUserUid();

    if (userUid != null) {
      final collectionReference = FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('Investment')
          .doc('InvestmentData');

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMonthlyReturn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Investment Allocation Overview',
          style: GoogleFonts.redHatDisplay(
              color: Colors.white, fontSize: 18, letterSpacing: 1.5),
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
          Center(
            child: SingleChildScrollView(
                child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchData2(), // Fetch portfolio investment data
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3A5F0B),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final investmentData = snapshot.data ?? [];
                        if (investmentData.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'No investments were found.\nAdd investments to view the analysis.',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green.shade900,
                                    letterSpacing: 1),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        final totalData =
                            calculateTotalPortfolioData(investmentData);

                        final totalInvestment = totalData['totalInvestment'];
                        final totalROI = totalData['totalROI'];

                        final returnPercentage =
                            (totalROI! / totalInvestment!) * 100;
                        final profit = totalROI > totalInvestment
                            ? totalROI - totalInvestment
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

                        return Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Investment :',
                                    style: GoogleFonts.redHatDisplay(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'en_IN',
                                      symbol: '₹ ',
                                    ).format(totalInvestment ?? 0),
                                    style: GoogleFonts.poppins(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Return : ' +
                                    NumberFormat.currency(
                                      locale: 'en_IN',
                                      symbol: '₹ ',
                                    ).format(totalROI ?? 0),
                                style: GoogleFonts.redHatDisplay(
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Return Ratio : ',
                                    style: GoogleFonts.redHatDisplay(
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '+${returnPercentage.toStringAsFixed(2)} %',
                                    style: GoogleFonts.redHatDisplay(
                                      color:
                                          const Color.fromARGB(255, 28, 83, 30),
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
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
                                      totalInvestment,
                                      totalROI,
                                      dataPoints,
                                    );
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Avg. Monthly Return : ',
                                              style: GoogleFonts.redHatDisplay(
                                                  letterSpacing: 0.5,
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
                                        SizedBox(
                                          height: 5,
                                        ),
                                        if (estimatedMonthsToProfit > 0)
                                          Text(
                                            ' Estimate profit within $estimatedMonthsToProfit Months',
                                            style: GoogleFonts.redHatDisplay(
                                                letterSpacing: 1,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio:
                                                1.8, // Adjust the aspect ratio to control pie chart size
                                            child: PieChart(
                                              PieChartData(
                                                sections: [
                                                  if (totalROI <
                                                      totalInvestment) // Show only when return is greater
                                                    PieChartSectionData(
                                                      color:
                                                          Colors.green.shade500,
                                                      value: totalROI,
                                                      showTitle: false,
                                                    ),
                                                  if (totalROI <
                                                      totalInvestment)
                                                    PieChartSectionData(
                                                      color: Colors.blue,
                                                      value: totalInvestment -
                                                          totalROI,
                                                      showTitle: false,
                                                    ),
                                                  if (totalROI >
                                                      totalInvestment)
                                                    PieChartSectionData(
                                                      color: Colors.blue,
                                                      value: totalROI - profit,
                                                      showTitle: false,
                                                    ),
                                                  if (totalROI >
                                                      totalInvestment) // Only show profit when return is greater
                                                    PieChartSectionData(
                                                      color: Colors.amber,
                                                      value: profit,
                                                      showTitle: false,
                                                    ),
                                                ],
                                                centerSpaceRadius:
                                                    40, // Adjust the center space radius
                                                sectionsSpace: 2,
                                              ),
                                            ),
                                          ),
                                          // Add spacing between pie chart and legend

                                          LegendWidget(
                                              totalInvestment: totalInvestment,
                                              returnAmount: totalROI,
                                              profit: profit),
                                          SizedBox(height: 45),
                                          NavChartPage(),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          LegendWidget2(
                                            totalInvestment: totalInvestment,
                                            returnAmount: totalROI,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class LegendWidget extends StatelessWidget {
  final double totalInvestment;
  final double returnAmount;
  final double profit;

  LegendWidget(
      {required this.totalInvestment,
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
  final double totalInvestment;
  final double returnAmount;

  LegendWidget2({
    required this.totalInvestment,
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
          color: Colors.blue,
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
