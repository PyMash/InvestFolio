import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LineGraph extends StatefulWidget {
  const LineGraph({Key? key});

  @override
  State<LineGraph> createState() => _LineGraphState();
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
  final String month;
  final double investmentAmount;

  DataPoint(this.month, this.investmentAmount);
}

class _LineGraphState extends State<LineGraph> {
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
            return DataPoint(
              dataPoint['month'] as String,
              dataPoint['investmentAmount'].toDouble(), // Convert to double
            );
          }).toList();
        } else {
          dataPoints = []; // Document does not exist, initialize as empty
        }
      } catch (e) {
        print("Error fetching investment data: $e");
        dataPoints = []; // Handle the error, initialize as empty
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double minY = double.infinity;
    double maxY = -double.infinity;

    if (dataPoints.isNotEmpty) {
      dataPoints.forEach((dataPoint) {
        minY = minY > dataPoint.investmentAmount
            ? dataPoint.investmentAmount
            : minY;
        maxY = maxY < dataPoint.investmentAmount
            ? dataPoint.investmentAmount
            : maxY;
      });
    } else {
      // Handle the case where there are no fetched data points
      minY = 0;
      maxY = 100000;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 160,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : LineChart(LineChartData(
                  minX: 0,
                  maxX: dataPoints.length - 1,
                  minY: minY,
                  maxY: maxY,
                  borderData: FlBorderData(show: false),
                  backgroundColor: Colors.white,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), entry.value.investmentAmount);
                      }).toList(),
                      isCurved: true,
                      gradient:
                          LinearGradient(colors: [Colors.black87, Colors.green]),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [
                          Colors.blueGrey.withOpacity(0.5),
                          Colors.green.withOpacity(0.5),
                        ]),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: false,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                          color: Colors.grey.shade800, strokeWidth: 0.8);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 12,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < dataPoints.length) {
                            final dataPoint = dataPoints[value.toInt()];
                            return Text(
                              "${dataPoint.month}".toUpperCase(),
                              style:
                                  GoogleFonts.lato(color: Colors.black, fontSize: 10,fontWeight: FontWeight.w600),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                )),
        ),
      ),
    );
  }
}
