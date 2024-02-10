import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
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
    setSystemUIColors();
    isDark = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 19,
                color: isDark ? whiteColor : blackColor,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
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
            color: isDark
                ? Colors.grey.shade800
                : Colors.blueGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          width: double.infinity,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  HomeMenuBtn(
                    label: 'Account',
                    child: GestureDetector(
                      onTap: () {
                        NavPush(
                            context,
                            AccountUI(
                              name: globalUser.name,
                              email: globalUser.email,
                            ));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: globalUser.imgUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    btnColor: Color.fromARGB(255, 210, 235, 255),
                  ),
                  HomeMenuBtn(
                    label: 'Logout',
                    child: IconButton(
                      onPressed: () {
                        AuthMethods.signOut(context);
                      },
                      icon: Icon(
                        Icons.logout,
                        color: isDark ? Colors.red.shade300 : Colors.red,
                      ),
                    ),
                    btnColor: isDark
                        ? Color(0xFF4B0000)
                        : Color.fromARGB(255, 255, 208, 205),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget HomeMenuBtn({final label, required Widget child, btnColor}) {
    return Column(
      children: [
        Container(
          height: sdp(context, 40),
          width: sdp(context, 40),
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? whiteColor : blackColor,
          ),
        ),
      ],
    );
  }
}
