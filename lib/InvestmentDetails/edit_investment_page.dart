import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:investfolio/InvestmentDetails/investment_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:investfolio/NavBar/mainPage.dart';

class EditInvestmentPopup extends StatefulWidget {
  final double initialInvestmentAmount;
  final double initialReturnAmount;
  final String documentId;

  EditInvestmentPopup({
    required this.initialInvestmentAmount,
    required this.initialReturnAmount,
    required this.documentId,
  });

  @override
  _EditInvestmentPopupState createState() => _EditInvestmentPopupState();
}

class _EditInvestmentPopupState extends State<EditInvestmentPopup> {
  final TextStyle labelTextStyle = TextStyle(
    color: Color(0xFF3A5F0B),
  );
  late double newInvestmentAmount;
  late double newReturnAmount;
  bool isAddButtonSelected = false;
  bool isReduceButtonSelected = false;
  bool isEditingInvestmentAmount = false;
  bool isEditingReturnAmount = false;
  String? validationError;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    newInvestmentAmount = 0.0;
    newReturnAmount = 0.0;
    selectedDate = null;
  }

  Future<void> updateFirestore() async {
    try {
      // Check if either "Add" or "Reduce" option is selected
      if (!isAddButtonSelected && !isReduceButtonSelected) {
        setState(() {
          validationError = 'Please select either "Add" or "Reduce".';
        });
        return; // Exit the function without updating Firestore
      }
      // Validate that a date has been selected
      if (selectedDate == null) {
        setState(() {
          validationError = 'Please select a date.';
        });
        return; // Exit the function without updating Firestore
      }

      // Reset the error message
      setState(() {
        validationError = null;
      });

      // Validate that at least one of the amounts is greater than zero
      if (newInvestmentAmount <= 0.0 && newReturnAmount <= 0.0) {
        setState(() {
          validationError =
              'At least one of the amounts must be greater than zero.';
        });
        return; // Exit the function without updating Firestore
      }

      // Format selectedDate to match the previous 'yearMonth' format
      String yearMonth = DateFormat('yyyy-MM').format(selectedDate!);

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

      // Check if the yearMonth already exists in data points
      bool yearMonthExistsInFirstLocation = false;
      for (int i = 0; i < existingFirstLocationDataPoints.length; i++) {
        if (existingFirstLocationDataPoints[i]['yearMonth'] == yearMonth) {
          // Subtract the roiAmount and newInvestmentAmount for "Reduce" operation
          existingFirstLocationDataPoints[i]['roiAmount'] -=
              (isReduceButtonSelected ? newReturnAmount : 0.0);
          existingFirstLocationDataPoints[i]['InvestmentAmount'] -=
              (isReduceButtonSelected ? newInvestmentAmount : 0.0);
          // Add the roiAmount and newInvestmentAmount for "Add" operation
          existingFirstLocationDataPoints[i]['roiAmount'] +=
              (isAddButtonSelected ? newReturnAmount : 0.0);
          existingFirstLocationDataPoints[i]['InvestmentAmount'] +=
              (isAddButtonSelected ? newInvestmentAmount : 0.0);
          yearMonthExistsInFirstLocation = true;
          break;
        }
      }

      // If the yearMonth doesn't exist, add a new data point
      if (!yearMonthExistsInFirstLocation) {
        Map<String, dynamic> newDataPoint = {
          'yearMonth': yearMonth,
          'roiAmount': (isAddButtonSelected ? newReturnAmount : 0.0),
          'InvestmentAmount': (isAddButtonSelected ? newInvestmentAmount : 0.0),
        };
        existingFirstLocationDataPoints.add(newDataPoint);
      }

      // Update Firestore document at the first location
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Investment')
          .doc('InvestmentData')
          .collection('Investments')
          .doc(widget.documentId)
          .update({
        'dataPoints': existingFirstLocationDataPoints,
      });

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

      // Check if the yearMonth already exists in data points
      bool yearMonthExistsInSecondLocation = false;
      for (int i = 0; i < existingSecondLocationDataPoints.length; i++) {
        if (existingSecondLocationDataPoints[i]['yearMonth'] == yearMonth) {
          // Subtract the roiAmount and newInvestmentAmount from the existing month for "Reduce" operation
          existingSecondLocationDataPoints[i]['roiAmount'] -=
              (isReduceButtonSelected ? newReturnAmount : 0.0);
          existingSecondLocationDataPoints[i]['InvestmentAmount'] -=
              (isReduceButtonSelected ? newInvestmentAmount : 0.0);
          // Add the roiAmount and newInvestmentAmount to the existing month for "Add" operation
          existingSecondLocationDataPoints[i]['roiAmount'] +=
              (isAddButtonSelected ? newReturnAmount : 0.0);
          existingSecondLocationDataPoints[i]['InvestmentAmount'] +=
              (isAddButtonSelected ? newInvestmentAmount : 0.0);
          yearMonthExistsInSecondLocation = true;
          break;
        }
      }

      // If the yearMonth doesn't exist, add a new data point
      if (!yearMonthExistsInSecondLocation) {
        Map<String, dynamic> newDataPoint = {
          'yearMonth': yearMonth,
          'roiAmount': (isAddButtonSelected ? newReturnAmount : 0.0),
          'InvestmentAmount': (isAddButtonSelected ? newInvestmentAmount : 0.0),
        };
        existingSecondLocationDataPoints.add(newDataPoint);
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
      // Fetch existing investment data
      final currentData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Investment')
          .doc('InvestmentData')
          .collection('Investments')
          .doc(widget.documentId)
          .get();

      final currentInvestmentAmount =
          double.tryParse(currentData.data()?['investmentAmount']) ?? 0.0;
      final currentReturnAmount =
          double.tryParse(currentData.data()?['returnAmount']) ?? 0.0;

      // Calculate the new values based on the operation type
      double updatedInvestmentAmount = currentInvestmentAmount;
      double updatedReturnAmount = currentReturnAmount;

      if (isAddButtonSelected) {
        updatedInvestmentAmount += newInvestmentAmount;
        updatedReturnAmount += newReturnAmount;
      } else if (isReduceButtonSelected) {
        updatedInvestmentAmount -= newInvestmentAmount;
        updatedReturnAmount -= newReturnAmount;
      }

      // Update Firestore document with the updated values
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Investment')
          .doc('InvestmentData')
          .collection('Investments')
          .doc(widget.documentId)
          .update({
        'investmentAmount': updatedInvestmentAmount.toString(),
        'returnAmount': updatedReturnAmount.toString(),
      });

      // Close the popup after saving
      Navigator.of(context).pop();

      // Refresh the screen to get the updated values
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              InvestmentDetailPage(documentId: widget.documentId),
        ),
      );
    } catch (e) {
      // Handle Firestore errors here
      print('Error updating Firestore: $e');
      setState(() {
        validationError = 'An error occurred while saving. Please try again.';
      });
    }
  }

  void toggleAddButton() {
    setState(() {
      isAddButtonSelected = true;
      isReduceButtonSelected = false;
    });
  }

  void toggleReduceButton() {
    setState(() {
      isReduceButtonSelected = true;
      isAddButtonSelected = false;
    });
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete?',
            style: GoogleFonts.redHatDisplay(letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'It will remove all records of this investment and deduct the amount from the overall investment and once deleted, it cannot be retrieved.',
            style: GoogleFonts.poppins(letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          // actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteInvestmentData();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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

      // Close the popup or navigate to another page as needed
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));

      // Display success message to the user
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Data deleted successfully.',
          style: GoogleFonts.poppins(letterSpacing: 1, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Delay before dismissing the snackbar
      // await Future.delayed(Duration(seconds: 2));

      // // Dismiss the snackbar
      // ScaffoldMessenger.of(context).removeCurrentSnackBar();
    } catch (e) {
      // Handle Firestore errors here
      print('Error deleting data: $e');
      // ignore: use_build_context_synchronously
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
    } finally {
      // Hide the circular progress indicator after completion (whether success or error)
      hideDeleteProgressDialog();
    }
  }

  void showDeleteProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(currentDate.year - 1),
      lastDate: currentDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            hintColor: Colors.green,
            colorScheme: ColorScheme.light(primary: Colors.green),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/invst2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          title: Center(
            child: Text(
              'Edit Investment',
              style: TextStyle(color: Color(0xFF3A5F0B)),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isAddButtonSelected)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                          ),
                          onPressed: toggleAddButton,
                          child: Text('Add',
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      if (isAddButtonSelected)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: toggleAddButton,
                            child: Text('Add',
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ),
                      SizedBox(width: 2),
                      if (!isReduceButtonSelected)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                          ),
                          onPressed: toggleReduceButton,
                          child: Text('Reduce',
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      if (isReduceButtonSelected)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: toggleReduceButton,
                            child: Text('Reduce',
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isEditingInvestmentAmount
                      ? TextField(
                          key: ValueKey<bool>(isEditingInvestmentAmount),
                          decoration: InputDecoration(
                            labelText: 'Investment Amount',
                            labelStyle: labelTextStyle,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF3A5F0B)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              newInvestmentAmount =
                                  double.tryParse(value) ?? 0.0;
                            });
                          },
                        )
                      : ElevatedButton(
                          key: ValueKey<bool>(isEditingInvestmentAmount),
                          onPressed: () {
                            setState(() {
                              isEditingInvestmentAmount = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Investment Amount',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.edit_note_sharp,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isEditingReturnAmount
                      ? Visibility(
                          visible: !isReduceButtonSelected,
                          child: TextField(
                            key: ValueKey<bool>(isEditingReturnAmount),
                            decoration: InputDecoration(
                              labelText: 'Return Amount',
                              labelStyle: labelTextStyle,
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF3A5F0B)),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                newReturnAmount = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        )
                      : Visibility(
                          visible: !isReduceButtonSelected,
                          child: ElevatedButton(
                            key: ValueKey<bool>(isEditingReturnAmount),
                            onPressed: () {
                              setState(() {
                                isEditingReturnAmount = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.transparent,
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Return Amount',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.edit_note,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ),
                ),
                // if (isAddButtonSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              selectedDate == null
                                  ? '   Select Date'
                                  : '   ${DateFormat('dd MMM yyyy').format(selectedDate!)}',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  letterSpacing: 1),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.calendar_month,
                              // size: 30,
                            ),
                          ],
                        ),
                      ),

                      // Use a calendar widget or integrate a date picker here
                    ],
                  ),
                ),
                if (validationError != null)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      validationError!,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 12.0,
                          color: Colors.red,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                _showConfirmationDialog();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                updateFirestore();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Save',
                  style: labelTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
