import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Functions/transactFunctions.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/services/user.dart';

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
      Map<String, dynamic> accountMap = {
        'name': nameController.text,
      };

      //  updating details in DB
      String message = await DatabaseMethods()
          .updateAccountDetails(UserDetails.uid, accountMap);

      //  updating details in shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('USERDISPLAYNAMEKEY', nameController.text);

      //  updating details in current session
      UserDetails.userDisplayName = nameController.text;

      ShowSnackBar(context, message);
    } else {
      ShowSnackBar(context, 'Please fill all the Fields');
    }
  }

  //------------------------->

  @override
  Widget build(BuildContext context) {
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
                          backgroundImage:
                              NetworkImage(UserDetails.userProfilePic),
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
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            fontSize: 25,
                            color: Colors.grey.shade400,
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
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.grey,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'UPDATE',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
