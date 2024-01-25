import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DataPoint {
  final String month;
  final double investmentAmount;

  DataPoint(this.month, this.investmentAmount);
}

class UploadData extends StatefulWidget {
  const UploadData({super.key});

  @override
  State<UploadData> createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  final List<DataPoint> dataPoints = [
    DataPoint('Jan', 25000),
    DataPoint('Feb', 14000),
    DataPoint('Mar', 85000),
    DataPoint('Apr', 72000),
    DataPoint('May', 95000),
    DataPoint('Jun', 45000),
    DataPoint('Aug', 65000),
    DataPoint('Sept', 65000),
    DataPoint('Oct', 65000),
  ];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadInvestmentData(
      String userUid, List<DataPoint> dataPoints) async {
    final collectionReference = _firestore
        .collection('users')
        .doc(userUid)
        .collection('Investment')
        .doc('InvestmentData');

    try {
      await collectionReference.set({
        'dataPoints': dataPoints.map((dataPoint) {
          return {
            'month': dataPoint.month,
            'investmentAmount': dataPoint.investmentAmount,
          };
        }).toList(),
      });
    } catch (e) {
      print("Error uploading investment data: $e");
    }
  }

  Future<void> addDataPoint(String userUid, DataPoint dataPoint) async {
    final collectionReference = _firestore.collection('users').doc(userUid).collection('Investment').doc('InvestmentData');
    
    try {
      // Get the existing data points
      final existingData = await collectionReference.get();
      final existingDataPoints = existingData.data()?['dataPoints'] as List<dynamic>;

      // Add the new data point to the existing data
      existingDataPoints.add({
        'month': dataPoint.month,
        'investmentAmount': dataPoint.investmentAmount,
      });

      // Update the Firestore document with the new data points
      await collectionReference.set({
        'dataPoints': existingDataPoints,
      });
    } catch (e) {
      print("Error adding data point: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () async {
          String userUid =
              'Vu018emxPXaPXaCz7VRxiV6SQda2';
          DataPoint newDataPoint = DataPoint('Nov', 60000);

          await addDataPoint(userUid, newDataPoint);
        },
        child: Text('Upload'),
      ),
    );
  }
}
