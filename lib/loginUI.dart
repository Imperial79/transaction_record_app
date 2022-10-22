import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/services/auth.dart';
import 'package:transaction_record_app/services/size.dart';
import 'package:transaction_record_app/widgets.dart';

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
                  child: Image.asset(
                    logoPath,
                    height: sdp(context, 60),
                  ),
                ),
              ),
              _isLoading
                  ? Flexible(
                      flex: 6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.5,
                              child: CircularProgressIndicator(
                                color: textLinkColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Fetching Your Transacts',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Flexible(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            // flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image.asset(
                                //   logoPath,
                                //   height: 100,
                                // ),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                Text(
                                  'Transact Record',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  'Your Personal Money Manager',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '#OpenSource',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: textLinkColor,
                                    fontWeight: FontWeight.w600,
                                    height: 1.7,
                                  ),
                                ),
                                TextLink(
                                  link: _githubLink,
                                  color: Colors.grey.shade700,
                                  alignment: Alignment.topLeft,
                                  text: '#Github',
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.backup,
                                color: textLinkColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  'SYNC YOUR DATA ON TRANSACT CLOUD',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: textLinkColor,
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.pink,
                                    Colors.pink.shade200,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 6,
                                    offset: Offset(0, 10),
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
                                  SizedBox(
                                    width: 10,
                                  ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextLink(
                                  text: 'Terms and Conditions',
                                  link: Uri.parse(''),
                                  color: textLinkColor,
                                  alignment: Alignment.bottomLeft,
                                ),
                              ),
                              Expanded(
                                child: TextLink(
                                  text: 'Privacy Policy',
                                  link: _privacyPolicyUrl,
                                  color: textLinkColor,
                                  alignment: Alignment.bottomRight,
                                ),
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

  Widget TextLink({final text, alignment, color, Uri? link}) {
    return InkWell(
      onTap: () {
        launchTheUrl(link!);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Align(
        alignment: alignment,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
