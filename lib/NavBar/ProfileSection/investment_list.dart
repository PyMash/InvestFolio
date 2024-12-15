import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investfolio/InvestmentDetails/investment_details_page.dart';

class MyListViewPage extends StatefulWidget {
  @override
  _MyListViewPageState createState() => _MyListViewPageState();
}

class _MyListViewPageState extends State<MyListViewPage> {
  late CollectionReference<Map<String, dynamic>> investmentCollection;

  @override
  void initState() {
    super.initState();
    investmentCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Investment')
        .doc('InvestmentData')
        .collection('Investments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Investment List',
          style: GoogleFonts.redHatDisplay(
              color: Colors.white, letterSpacing: 1.5),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: investmentCollection.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          var documents = snapshot.data?.docs;

          if (documents == null || documents.isEmpty) {
            return Center(
              child: Text('No investments found.'),
            );
          }

          return Stack(
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
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1.7,
                    // color: Colors.red,
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        var document = documents[index];
                        var investmentName = document.data()?['investmentName'];
                        var investmenttype = document.data()?['investmentType'];
                        var documentId = document.id;

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green.shade900,
                                borderRadius: BorderRadius.circular(5)),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      investmentName.toString().toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.redHatDisplay(
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Flexible(
                                    child: Text(
                                      '($investmenttype)',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                print(documentId);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => InvestmentDetailPage(
                                        documentId: documentId),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
