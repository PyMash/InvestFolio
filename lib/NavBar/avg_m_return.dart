import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataPoint {
  final int month;
  final double roiAmount;
  final double investmentAmount;
  final int year;

  DataPoint(this.month, this.roiAmount, this.investmentAmount, this.year);
}

class AvgMonthlyReturn extends StatefulWidget {
  @override
  _AvgMonthlyReturnState createState() => _AvgMonthlyReturnState();
}

class _AvgMonthlyReturnState extends State<AvgMonthlyReturn> {
  List<DataPoint> dataPoints = [];
  bool isLoadingMR = true;

  @override
  void initState() {
    super.initState();
    fetchMonthlyReturn();
  }

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
    double totalROI = 0;
    int monthsWithPositiveROI = 0;

    for (DataPoint dataPoint in dataPoints) {
      if (dataPoint.roiAmount > 0) {
        totalROI += dataPoint.roiAmount;
        monthsWithPositiveROI++;
      }
    }

    return monthsWithPositiveROI > 0
        ? totalROI / monthsWithPositiveROI
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NavChart Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Average Monthly Return:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            FutureBuilder<void>(
              future: fetchMonthlyReturn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  double avgMonthlyReturn = getAvgMonthlyReturn(dataPoints);
                  return Text(
                    'Rs.${avgMonthlyReturn.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
