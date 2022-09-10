import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUi.dart';
import 'package:transaction_record_app/services/database.dart';

class SetBalanceUi extends StatefulWidget {
  @override
  _SetBalanceUiState createState() => _SetBalanceUiState();
}

class _SetBalanceUiState extends State<SetBalanceUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final initialBalanceController = TextEditingController();

  onClick() {
    setState(() {
      if (UserDetails.userName != '' && initialBalanceController.text != '') {
        FirebaseFirestore.instance
            .collection('users')
            .doc(UserDetails.uid)
            .update({
          'currentBalance': double.parse(initialBalanceController.text)
        });

        setState(() {});
        NavPushReplacement(context, HomeUi());
        ShowSnackBar(context, 'Current balance updated');
      } else {
        ShowSnackBar(context, "Please Wait or Try again after sometime");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Set Balance",
                style: TextStyle(
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
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  fontSize: 17,
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 200,
                    child: TextField(
                      controller: initialBalanceController,
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
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 30,
                        ),
                        prefixText: "INR. ",
                        prefixStyle: TextStyle(
                          fontSize: 25,
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                            width: 3,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                            width: 3,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onClick();
        },
        heroTag: 'btn1',
        elevation: 0,
        backgroundColor: Colors.grey.shade700,
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
