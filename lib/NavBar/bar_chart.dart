import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BarGraph extends StatefulWidget {
  BarGraph({
    Key? key,
  });

  @override
  State<BarGraph> createState() => _BarGraphState();
}

Future<String?> getCurrentUserUid() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid;
  } else {
    return null; // No user is currently logged in
  }
}

class DataPoint {
  final int month;
  final double roiAmount;
  final double investmentAmount;
  final int year;

  DataPoint(this.month, this.roiAmount, this.investmentAmount, this.year);
}

class _BarGraphState extends State<BarGraph> {
  List<DataPoint> dataPoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvestmentData();
  }

  Future<void> fetchInvestmentData() async {
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
          dataPoints = dataPoints.length > 6
              ? dataPoints.sublist(dataPoints.length - 6)
              : dataPoints;

          // Use setState only if the widget is still mounted
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          dataPoints = [];
          // Use setState only if the widget is still mounted
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } catch (e) {
        print("Error fetching investment data: $e");
        dataPoints = [];
        // Use setState only if the widget is still mounted
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxY = -double.infinity;

    if (dataPoints.isNotEmpty) {
      dataPoints.forEach((dataPoint) {
        maxY = maxY < dataPoint.roiAmount ? dataPoint.roiAmount : maxY;
        maxY = maxY < dataPoint.investmentAmount
            ? dataPoint.investmentAmount
            : maxY;
      });
    } else {
      // Handle the case where there are no fetched data points
      maxY = 100000;
    }
    maxY = (maxY + maxY * 0.25).floorToDouble();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: SizedBox(
            height: 160,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: const Color.fromARGB(255, 7, 59, 9),
                    ),
                  )
                : (dataPoints.length < 2)
                    ? Center(
                        child: Text("Need at least two months of data to show"),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          groupsSpace: 12,
                          // Replace this section in the BarChart widget
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.transparent,
                            ),
                            handleBuiltInTouches: true,
                          ),

                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 12,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value >= 0 && value < dataPoints.length) {
                                    final dataPoint = dataPoints[value.toInt()];
                                    // Display month and year
                                    // final monthYear = "${dataPoint.month}.${dataPoint.year % 100}";
                                    final date = DateTime(
                                        dataPoint.year, dataPoint.month);
                                    return Text(
                                      "${DateFormat('MMM yy').format(date)}"
                                          .toUpperCase(),
                                      style: GoogleFonts.lato(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: dataPoints
                              .asMap()
                              .entries
                              .map(
                                (entry) => BarChartGroupData(
                                  x: entry.key,
                                  barsSpace: 4,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.investmentAmount,
                                      color: Colors.cyan,
                                    ),
                                    BarChartRodData(
                                      toY: entry.value.roiAmount,
                                      color: Colors.green,
                                    ),
                                  ],
                                  showingTooltipIndicators: [0, 1],
                                ),
                              )
                              .toList(),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
