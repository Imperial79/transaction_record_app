import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/services/auth.dart';
import 'package:transaction_record_app/services/size.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/widgets.dart';

class HomeMenuUI extends StatefulWidget {
  const HomeMenuUI({Key? key}) : super(key: key);

  @override
  State<HomeMenuUI> createState() => _HomeMenuUIState();
}

class _HomeMenuUIState extends State<HomeMenuUI> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 19,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          color: Colors.blueGrey.withOpacity(0.1),
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // HomeMenuBtn(
                  //   onPress: () {
                  //     NavPush(
                  //         context,
                  //         AccountUI(
                  //           name: UserDetails.userDisplayName,
                  //           email: UserDetails.userEmail,
                  //         ));
                  //   },
                  //   label: 'Account',
                  //   icon: Icon(Icons.person, color: Colors.blue.shade700),
                  //   btnColor: Color.fromARGB(255, 210, 235, 255),
                  //   textColor: Colors.blue.shade700,
                  // ),
                  HomeMenuBtn(
                    label: 'Account',
                    child: GestureDetector(
                      onTap: () {
                        NavPush(
                            context,
                            AccountUI(
                              name: UserDetails.userDisplayName,
                              email: UserDetails.userEmail,
                            ));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: UserDetails.userProfilePic,
                        ),
                      ),
                    ),
                    btnColor: Color.fromARGB(255, 210, 235, 255),
                    textColor: Colors.grey.shade100,
                  ),
                  HomeMenuBtn(
                    label: 'Logout',
                    child: IconButton(
                      onPressed: () {
                        AuthMethods().signOut(context);
                      },
                      icon: Icon(Icons.logout, color: Colors.red),
                    ),
                    btnColor: Color.fromARGB(255, 255, 208, 205),
                    textColor: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget HomeMenuBtn(
      {final label, required Widget child, btnColor, textColor}) {
    return Column(
      children: [
        Container(
          height: sdp(context, 40),
          width: sdp(context, 40),
          decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: textColor)),
          child: child,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
