// ignore_for_file: non_constant_identifier_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                                    const Text(
                                      'Transact Record',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Serif",
                                      ),
                                    ),
                                    Text(
                                      'Your Personal Money Manager',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? Dark.primary
                                            : Light.primary,
                                      ),
                                    ),
                                    height20,
                                    Text(
                                      '#FOSS',
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
                                  Icon(
                                    Icons.cloud,
                                    color: isDark
                                        ? Dark.profitText
                                        : Light.profitText,
                                  ),
                                  width10,
                                  Expanded(
                                    child: Text(
                                      'SYNC YOUR DATA ON TRANSACT CLOUD FOR FREE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: isDark
                                            ? Dark.profitText
                                            : Light.profitText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              height20,
                              InkWell(
                                borderRadius: kRadius(15),
                                splashColor: Colors.red,
                                onTap: () async {
                                  _googleSignIn();
                                },
                                child: Ink(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: kRadius(10),
                                    color:
                                        isDark ? Dark.lossCard : Light.lossCard,
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
                              height15,
                              Text.rich(
                                style: TextStyle(fontSize: 16),
                                TextSpan(
                                  children: [
                                    TextSpan(
                                        text:
                                            "By signing in, you agree with our "),
                                    TextSpan(
                                      text: "Terms & Conditions ",
                                      style: TextStyle(
                                        color: isDark
                                            ? Dark.profitText
                                            : Light.profitText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(text: "and "),
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          await launchTheUrl(_privacyPolicyUrl);
                                        },
                                      text: "Privacy Policy.",
                                      style: TextStyle(
                                        color: isDark
                                            ? Dark.profitText
                                            : Light.profitText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
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
              "₹",
              style: TextStyle(
                fontSize: 400,
                height: 1,
                fontFamily: "Serif",
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
