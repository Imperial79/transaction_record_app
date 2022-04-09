import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/homeUi.dart';
import 'package:transaction_record_app/services/database.dart';

class SetBalanceUi extends StatefulWidget {
  @override
  _SetBalanceUiState createState() => _SetBalanceUiState();
}

class _SetBalanceUiState extends State<SetBalanceUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController initialBalance = TextEditingController();

  onClick() {
    setState(() {
      if (UserDetails.userName != '' && initialBalance.text != '') {
        CurrentBalance.globalCurrentBalance = int.parse(initialBalance.text);

        Map<String, String> balanceMap = {'amount': initialBalance.text};
        FirebaseFirestore.instance
            .collection('users')
            .doc(UserDetails.uid)
            .update({'currentBalance': initialBalance.text});

        setState(() {});

        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => HomeUi()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please Wait and Try again after sometime",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Set Balance",
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 40,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Enter your current balance in cash to keep track of your daily expenses",
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    fontSize: 17,
                  ),
                ),
                SizedBox(
                  height: 120,
                ),
                Center(
                  child: Container(
                    width: 200,
                    child: TextField(
                      controller: initialBalance,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        fillColor: primaryColor,
                        hintText: '00.0',
                        hintStyle: GoogleFonts.raleway(
                          color: Colors.grey,
                          fontSize: 30,
                        ),
                        prefixText: "INR. ",
                        prefixStyle: TextStyle(
                          fontSize: 25,
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 10,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          onClick();
        },
        heroTag: 'btn1',
        elevation: 0,
        backgroundColor: Colors.grey.shade700,
        child: Icon(Icons.arrow_forward_ios_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
