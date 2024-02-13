import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/services/auth.dart';
import 'package:transaction_record_app/services/user.dart';
import '../../Utility/colors.dart';
import '../../Utility/components.dart';
import '../../Utility/sdp.dart';

class HomeMenuUI extends StatefulWidget {
  const HomeMenuUI({Key? key}) : super(key: key);

  @override
  State<HomeMenuUI> createState() => _HomeMenuUIState();
}

class _HomeMenuUIState extends State<HomeMenuUI> {
  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: sdp(context, 10),
                      color: isDark ? whiteColor : blackColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? DarkColors.scaffold : LightColors.scaffold,
                borderRadius: kRadius(20),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HomeMenuBtn(
                        label: 'Account',
                        borderColor:
                            isDark ? DarkColors.fadeText : LightColors.fadeText,
                        child: GestureDetector(
                          onTap: () {
                            NavPush(context, AccountUI());
                          },
                          child: ClipRRect(
                            borderRadius: kRadius(20),
                            child: CachedNetworkImage(
                              imageUrl: globalUser.imgUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        btnColor: Color.fromARGB(255, 210, 235, 255),
                      ),
                      // HomeMenuBtn(
                      //   label: 'Switch',
                      //   borderColor:
                      //       isDark ? Colors.black : Colors.amber.shade900,
                      //   child: IconButton(
                      //     onPressed: () async {
                      //       await AuthMethods.signOut(context);

                      //       await AuthMethods.signInWithgoogle(context);
                      //     },
                      //     icon: Icon(
                      //       Icons.switch_account_rounded,
                      //       color:
                      //           isDark ? Colors.black : Colors.amber.shade900,
                      //     ),
                      //   ),
                      //   btnColor: isDark
                      //       ? Colors.yellow.shade900
                      //       : Colors.amber.shade200,
                      // ),
                      HomeMenuBtn(
                        label: 'Logout',
                        borderColor:
                            isDark ? Colors.red.shade300 : Colors.red.shade900,
                        child: IconButton(
                          onPressed: () {
                            AuthMethods.signOut(context);
                          },
                          icon: Icon(
                            Icons.logout,
                            color: isDark ? Colors.white : Colors.red.shade900,
                          ),
                        ),
                        btnColor: isDark
                            ? Colors.red.shade900
                            : Color.fromARGB(255, 255, 208, 205),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget HomeMenuBtn(
      {final label,
      required Widget child,
      Color? btnColor,
      Color? borderColor}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: sdp(context, 40),
            width: sdp(context, 40),
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: kRadius(20),
              border: Border.all(color: borderColor ?? Colors.black),
            ),
            child: child,
          ),
          height5,
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? whiteColor : blackColor,
              fontSize: sdp(context, 10),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
