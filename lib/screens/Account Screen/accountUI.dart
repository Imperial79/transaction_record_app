import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUi.dart';

import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/services/user.dart';

import '../../Utility/colors.dart';
import '../../Utility/components.dart';

class AccountUI extends StatefulWidget {
  final name, email;

  const AccountUI({Key? key, this.name, this.email}) : super(key: key);

  @override
  State<AccountUI> createState() => _AccountUIState();
}

class _AccountUIState extends State<AccountUI> {
  //-------------------->
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  //------------------->
  @override
  void initState() {
    super.initState();
    setState(() {
      nameController.text = widget.name;
      emailController.text = widget.email;
    });
  }

  updateAccountDetails() async {
    if (nameController.text.isNotEmpty) {
      FirebaseAuth.instance.currentUser!.updateDisplayName(nameController.text);

      // Map<String, dynamic> accountMap = {
      //   'name': nameController.text,
      // };

      // //  updating details in DB
      // String message = await DatabaseMethods()
      //     .updateAccountDetails(UserDetails.uid, accountMap);

      // final _userBox = await Hive.openBox("USERBOX");
      // _userBox.put('userData', {'name': nameController.text});
      // log("${_userBox.get('userData')}");

      // setState(() {
      //   displayNameGlobal.value = nameController.text;
      //   UserDetails.name = nameController.text;
      // });

      ShowSnackBar(context, "Name Updated");
    } else {
      ShowSnackBar(context, 'Please fill all the Fields');
    }
  }

  //------------------------->

  @override
  Widget build(BuildContext context) {
    setSystemUIColors();
    isDark = checkForTheme(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Hero(
                        tag: 'profImg',
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(UserDetails.imgUrl),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'UID: ${UserDetails.uid}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextField(
                        controller: nameController,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                        cursorWidth: 1,
                        cursorColor: isDark ? Colors.white : Colors.black,
                        decoration: InputDecoration(
                          focusColor: isDark ? Colors.white : Colors.black,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: isDark ? Colors.white : Colors.black,
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  isDark ? Colors.grey : Colors.grey.shade300,
                            ),
                          ),
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            fontSize: 25,
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: emailController,
                        enabled: false,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorWidth: 1,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          focusColor: Colors.black,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: MaterialButton(
          onPressed: () {
            updateAccountDetails();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
          child: Ink(
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 25,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? darkProfitColorAccent : blackColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  color: isDark ? Colors.black : Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'UPDATE',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
