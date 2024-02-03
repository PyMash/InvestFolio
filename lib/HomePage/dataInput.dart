import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DataInputDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddData;

  DataInputDialog({required this.onAddData});

  @override
  _DataInputDialogState createState() => _DataInputDialogState();
}

class _DataInputDialogState extends State<DataInputDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController investmentTypeController =
      TextEditingController();
  final TextEditingController investmentNameController =
      TextEditingController();
  final TextEditingController investmentAmountController =
      TextEditingController();
  final TextEditingController returnAmountController = TextEditingController();
  DateTime StartingInvestmentDate = DateTime.now();

  // Define a custom TextStyle for the label text
  final TextStyle labelTextStyle = GoogleFonts.redHatDisplay(
      color: Colors.black, // Label text color
      letterSpacing: 1);

  void showPopupMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert",style: GoogleFonts.poppins(letterSpacing: 1,color: Color(0xFF3A5F0B)),textAlign: TextAlign.center,),
          content: Text(
            "If you are unsure of your monthly returns, Enter total return amount here, and we'll spread them evenly across the months. Or enter 0 to continue now and head to the Edit Investment section to add specific return amounts for each month later on!",style: GoogleFonts.roboto(letterSpacing: 1),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK",style: GoogleFonts.poppins(color: Color(0xFF3A5F0B)),),
            ),
          ],
        );
      },
    );
  }

  void _handleAddData() {
  if (_formKey.currentState!.validate()) {
    final investmentType = investmentTypeController.text;
    final investmentName = investmentNameController.text;
    final investmentAmount = investmentAmountController.text;
    final returnAmount = returnAmountController.text;

    final newData = {
      'investmentType': investmentType,
      'investmentName': investmentName,
      'investmentAmount': investmentAmount,
      'returnAmount': returnAmount,
      'StartingInvestmentDate': StartingInvestmentDate,
    };

    // Store the parent context before calling the asynchronous function
    BuildContext parentContext = context;

    // Call the asynchronous function with the stored parent context
    widget.onAddData(newData,);

    Navigator.of(context).pop(); // Close the dialog
  }
}


  bool isDouble(String value) {
    try {
      double.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Investment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A5F0B),
                  ),
                ),
                TextFormField(
                  textAlign: TextAlign.center,
                  controller: investmentTypeController,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: "Like Direct Investment, Stock Market, etc",
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    // labelText: 'Investment type',
                    labelStyle: labelTextStyle,
                    label: Center(child: Text('Investment type')),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF3A5F0B),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter investment type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  textAlign: TextAlign.center,
                  controller: investmentNameController,
                  decoration: InputDecoration(
                    // labelText: 'Investment name',
                    labelStyle: labelTextStyle,
                    alignLabelWithHint: true,
                    hintText: "Like Investment 1 or through xyz ",
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    label: Center(
                      child: Text('Investment name'),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF3A5F0B),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter investment name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  textAlign: TextAlign.center,
                  controller: investmentAmountController,
                  decoration: InputDecoration(
                    // labelText: 'Invested amount',
                    label: Center(
                      child: Text('Invested amount'),
                    ),
                    labelStyle: labelTextStyle,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF3A5F0B),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter invested amount';
                    }
                    if (!isDouble(value)) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  onTap: () {
                    showPopupMessage(context);
                  },
                  textAlign: TextAlign.center,
                  controller: returnAmountController,
                  decoration: InputDecoration(
                    // labelText: 'Return received',
                    label: Center(
                      child: Text('Return received'),
                    ),
                    labelStyle: labelTextStyle,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF3A5F0B),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter return received';
                    }
                    if (!isDouble(value)) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: () {
                    _showMonthYearPicker(context);
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text:
                            DateFormat('MMMM y').format(StartingInvestmentDate),
                      ),
                      decoration: InputDecoration(
                        // labelText: "When did you start investing?",
                        label: Center(
                          child: Text('When did you start investing?'),
                        ),
                        labelStyle: labelTextStyle,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF3A5F0B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleAddData,
                    child: Text(
                      'Add',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3A5F0B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    // showPopupMessage(context);
    DateTime initialDate = StartingInvestmentDate;
    DateTime lastDate = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF3A5F0B),
            hintColor: const Color(0xFF3A5F0B),
            colorScheme: ColorScheme.light(primary: const Color(0xFF3A5F0B)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != StartingInvestmentDate) {
      setState(() {
        StartingInvestmentDate = picked;
      });
    }
  }
}
