import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/customScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUI.dart';

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
      // nameController.text = widget.name;

      nameController.text = globalUser.name;
      emailController.text = globalUser.email;
      // emailController.text = widget.email;
    });
  }

  updateAccountDetails() async {
    setState(() => isLoading = true);
    if (nameController.text.isNotEmpty) {
      Map<String, dynamic> accountMap = {
        'name': nameController.text,
      };

      await DatabaseMethods().updateAccountDetails(globalUser.uid, accountMap);

      final _userBox = await Hive.openBox("USERBOX");
      final _userMap = _userBox.get("userData");
      if (_userMap != null) {
        _userMap['userDisplayName'] = nameController.text;
        _userBox.put('userData', _userMap);
      }
      log("After Update-> ${_userBox.get('userData')}");

      setState(() {
        displayNameGlobal.value = nameController.text;
        globalUser.name = nameController.text;
      });

      ShowSnackBar(context, content: "Name Updated");
      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      ShowSnackBar(context,
          content: 'Please fill all the Fields', isDanger: true);
    }
  }

  //------------------------->
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    isDark = checkForTheme(context);
    return KScaffold(
      isLoading: isLoading,
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
                      height20,
                      Hero(
                        tag: 'profImg',
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(globalUser.imgUrl),
                        ),
                      ),
                      height10,
                      Row(
                        children: [
                          Icon(
                            Icons.tag,
                            color: isDark
                                ? DarkColors.fadeText
                                : LightColors.fadeText,
                          ),
                          width5,
                          Flexible(
                            child: Text(
                              globalUser.username,
                              style: TextStyle(
                                fontSize: 20,
                                color: isDark
                                    ? DarkColors.fadeText
                                    : LightColors.fadeText,
                              ),
                            ),
                          ),
                        ],
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
      floatingActionButton: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: MaterialButton(
            onPressed: () {
              updateAccountDetails();
            },
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(12),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
            child: Ink(
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 25,
              ),
              decoration: BoxDecoration(
                borderRadius: kRadius(12),
                color: isDark
                    ? DarkColors.primaryButton
                    : LightColors.primaryButton,
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
                    'Update',
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
      ),
    );
  }
}
