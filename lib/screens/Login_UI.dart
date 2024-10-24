// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/rootUI.dart';

import '../Utility/commons.dart';

class LoginUI extends ConsumerStatefulWidget {
  const LoginUI({super.key});

  @override
  ConsumerState<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends ConsumerState<LoginUI> {
  final Uri _privacyPolicyUrl = Uri.parse(
      'https://www.freeprivacypolicy.com/live/d6175538-7c18-42f4-989e-2c6351204f4b');

  bool isLoading = false;
  String logoPath = 'lib/assets/logo/logo.png';

  _googleSignIn() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = await ref.read(authRepository).signIn();

      if (user != null) {
        ref.read(userProvider.notifier).state = user;
        navPopUntilPush(context, RootUI());
      }
    } catch (e) {
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return KScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              _backgroundGraphics(),
              Column(
                children: [
                  isLoading
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
                                    const Text(
                                      'Transact Record',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(
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
                                    Text(
                                      '#Github',
                                      style: TextStyle(
                                        color: isDark
                                            ? Dark.profitText
                                            : Light.profitText,
                                        fontWeight: FontWeight.w600,
                                        height: 1.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'lib/assets/icons/cloud.svg',
                                    colorFilter: svgColor(
                                      isDark
                                          ? Dark.profitText
                                          : Light.profitText,
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
                              const SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                borderRadius: kRadius(15),
                                splashColor: Colors.red,
                                onTap: () async {
                                  // setState(() => isLoading = true);
                                  // String res =
                                  //     await AuthMethods.signIn(context);
                                  // if (res == 'fail') {
                                  //   if (mounted) {
                                  //     setState(() => isLoading = false);
                                  //   }
                                  // }
                                  _googleSignIn();
                                },
                                child: Ink(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: kRadius(10),
                                    color:
                                        isDark ? Dark.lossCard : Light.lossCard,
                                    // color: Color(0xffda8363),
                                    border:
                                        Border.all(color: Colors.red.shade100),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 7, horizontal: 20),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      width10,
                                      const Text(
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
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'By signing in, you agree with our ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextLink(
                                    text: 'Terms and Conditions',
                                    link: Uri.parse(''),
                                    color: isDark
                                        ? Dark.profitText
                                        : Light.profitText,
                                    textAlign: TextAlign.start,
                                  ),
                                  TextLink(
                                    text: 'Privacy Policy',
                                    link: _privacyPolicyUrl,
                                    color: isDark
                                        ? Dark.profitText
                                        : Light.profitText,
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Center _backgroundGraphics() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor =
        isDark ? Colors.white.withOpacity(.1) : Colors.black.withOpacity(.05);
    return Center(
      child: FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "T₹ansact",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 100,
                height: 1,
                color: textColor,
              ),
            ),
            Text(
              "Record",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 100,
                height: 1,
                color: textColor,
              ),
            ),
            Text(
              "₹",
              style: TextStyle(
                fontSize: 400,
                height: 1,
                fontFamily: "",
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Flexible _loadingScreen() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
            const SizedBox(
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
        padding: const EdgeInsets.all(5),
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
