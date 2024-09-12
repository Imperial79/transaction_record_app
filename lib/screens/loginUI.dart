// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/services/auth.dart';

import '../Utility/commons.dart';

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
    isDark = Theme.of(context).brightness == Brightness.dark;

    return KScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
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
                                Image.asset(
                                  logoPath,
                                  height: 70,
                                ),
                                height10,
                                Text(
                                  'Transact Record',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '"Your Personal Money Manager"',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                height20,
                                Text(
                                  '#OpenSource',
                                  style: TextStyle(
                                    color: isDark
                                        ? Dark.profitText
                                        : Light.profitText,
                                    fontWeight: FontWeight.w600,
                                    height: 1.7,
                                  ),
                                ),
                                TextLink(
                                  link: _githubLink,
                                  color: isDark
                                      ? Dark.profitText
                                      : Light.profitText,
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
                                  isDark ? Dark.profitText : Light.profitText,
                                ),
                                height: 20,
                              ),
                              width10,
                              Expanded(
                                child: Text(
                                  'SYNC YOUR DATA ON TRANSACT CLOUD FOR FREE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: isDark
                                        ? Dark.profitText
                                        : Light.profitText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            borderRadius: kRadius(15),
                            splashColor: Colors.red,
                            onTap: () async {
                              setState(() => _isLoading = true);
                              String res = await AuthMethods.signIn(context);
                              if (res == 'fail') {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                            child: Ink(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: kRadius(10),
                                color: isDark ? Dark.lossCard : Light.lossCard,
                                // color: Color(0xffda8363),
                                border: Border.all(color: Colors.red.shade100),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 30,
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                                color:
                                    isDark ? Dark.profitText : Light.profitText,
                                textAlign: TextAlign.start,
                              ),
                              TextLink(
                                text: 'Privacy Policy',
                                link: _privacyPolicyUrl,
                                color:
                                    isDark ? Dark.profitText : Light.profitText,
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
                color: isDark ? Dark.profitCard : Light.profitCard,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Fetching Your Transacts',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
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
