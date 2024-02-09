import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/services/auth.dart';

import '../Utility/sdp.dart';

class LoginUI extends StatefulWidget {
  LoginUI({Key? key}) : super(key: key);

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  Uri _privacyPolicyUrl = Uri.parse(
      'https://www.freeprivacypolicy.com/live/d6175538-7c18-42f4-989e-2c6351204f4b');

  Uri _githubLink =
      Uri.parse('https://github.com/Imperial79/transaction_record_app');

  bool _isLoading = false;
  String logoPath = 'lib/assets/logo/logo.png';

  @override
  Widget build(BuildContext context) {
    setSystemUIColors();
    isDark = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Spacer(),
              Flexible(
                flex: 1,
                child: AnimatedAlign(
                  duration: Duration(milliseconds: 300),
                  alignment: _isLoading
                      ? Alignment.bottomCenter
                      : Alignment.bottomLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.grey : Colors.tealAccent,
                          blurRadius: 100,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      logoPath,
                      height: sdp(context, 60),
                    ),
                  ),
                ),
              ),
              _isLoading
                  ? _loadingScreen()
                  : Flexible(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Transact Record',
                                  style: TextStyle(
                                    fontSize: sdp(context, 25),
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? greyColorAccent : blackColor,
                                  ),
                                ),
                                SizedBox(
                                  height: sdp(context, 10),
                                ),
                                Text(
                                  'Your Personal Money Manager',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark ? greyColorAccent : blackColor,
                                  ),
                                ),
                                Text(
                                  '#OpenSource',
                                  style: TextStyle(
                                    color: isDark
                                        ? profitHighlightColor
                                        : textLinkColor,
                                    fontWeight: FontWeight.w600,
                                    height: 1.7,
                                  ),
                                ),
                                TextLink(
                                  link: _githubLink,
                                  color: isDark
                                      ? profitHighlightColor
                                      : textLinkColor,
                                  text: '#Github',
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'lib/assets/icons/cloud.svg',
                                colorFilter: svgColor(
                                  isDark ? profitHighlightColor : textLinkColor,
                                ),
                                height: sdp(context, 20),
                              ),
                              width10,
                              Expanded(
                                child: Text(
                                  'SYNC YOUR DATA ON TRANSACT CLOUD FOR FREE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: sdp(context, 10),
                                    color: isDark
                                        ? profitHighlightColor
                                        : textLinkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            splashColor: Colors.red,
                            onTap: () async {
                              setState(() => _isLoading = true);
                              String res =
                                  await AuthMethods().signInWithgoogle(context);
                              if (res == 'fail') {
                                setState(() => _isLoading = false);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(0xffda8363),
                                border: Border.all(color: Colors.red.shade100),
                                // gradient: LinearGradient(
                                //   colors: [
                                //     Colors.pink,
                                //     Colors.pink.shade200,
                                //   ],
                                // ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.pink.withOpacity(0.5)
                                        : Colors.pinkAccent.withOpacity(0.4),
                                    blurRadius: 90,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  width10,
                                  Text(
                                    "Login with Google",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'By signing in, you agree with our ',
                            style: TextStyle(
                              fontSize: sdp(context, 10),
                              fontWeight: FontWeight.w600,
                              color: isDark ? greyColorAccent : blackColor,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextLink(
                                text: 'Terms and Conditions',
                                link: Uri.parse(''),
                                color: isDark
                                    ? profitHighlightColor
                                    : textLinkColor,
                                textAlign: TextAlign.start,
                              ),
                              TextLink(
                                text: 'Privacy Policy',
                                link: _privacyPolicyUrl,
                                color: isDark
                                    ? profitHighlightColor
                                    : textLinkColor,
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Flexible _loadingScreen() {
    return Flexible(
      flex: 6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.5,
              child: CircularProgressIndicator(
                color: isDark ? profitHighlightColor : primaryColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Fetching Your Transacts',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? whiteColor : Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget TextLink({final text, Color? color, Uri? link, TextAlign? textAlign}) {
    return TextButton(
      onPressed: () {
        launchTheUrl(link!);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(5),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        textAlign: textAlign,
      ),
    );
  }
}
