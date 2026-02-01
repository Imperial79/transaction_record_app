// ignore_for_file: non_constant_identifier_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/Helper/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/userModel.dart';

import '../Utility/commons.dart';

class LoginUI extends ConsumerStatefulWidget {
  const LoginUI({super.key});

  @override
  ConsumerState<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends ConsumerState<LoginUI> {
  final Uri _privacyPolicyUrl = Uri.parse(
    'https://www.freeprivacypolicy.com/live/d6175538-7c18-42f4-989e-2c6351204f4b',
  );

  final isLoading = ValueNotifier(false);
  String logoPath = 'lib/assets/logo/logo.png';

  Future<void> _googleSignIn() async {
    try {
      isLoading.value = true;
      UserModel? user;
      user = await ref.read(authRepository).signIn();

      if (user != null) {
        ref.read(userProvider.notifier).state = user;
        // navPopUntilPush(context, RootUI());
        context.pushReplacement('/root');
      }
    } catch (e) {
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              _backgroundGraphics(),
              ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (context, loading, child) {
                  return Column(
                    children: [
                      if (loading)
                        _loadingScreen()
                      else
                        Flexible(
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
                                      'Transact',
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
                                        color: context.primaryColor,
                                      ),
                                    ),
                                    height20,
                                    Text(
                                      '#FOSS',
                                      style: TextStyle(
                                        color: context.profitColor,
                                        fontWeight: FontWeight.w600,
                                        height: 1.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.cloud, color: context.profitColor),
                                  width10,
                                  Expanded(
                                    child: Text(
                                      'SYNC YOUR DATA ON TRANSACT CLOUD FOR FREE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: context.profitColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              height20,
                              InkWell(
                                borderRadius: kRadius(15),
                                onTap: () async {
                                  _googleSignIn();
                                },
                                child: Ink(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: kRadius(12),
                                    color: context.isDarkMode
                                        ? Light.scaffold
                                        : Dark.scaffold,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login,
                                        color: context.isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      width15,
                                      Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: context.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              height15,
                              Text.rich(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.fadeTextColor,
                                ),
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text:
                                          "By signing in, you agree with our ",
                                    ),
                                    TextSpan(
                                      text: "Terms & Conditions ",
                                      style: TextStyle(
                                        color: context.linkColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(text: "and "),
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          await launchTheUrl(_privacyPolicyUrl);
                                        },
                                      text: "Privacy Policy.",
                                      style: TextStyle(
                                        color: context.linkColor,
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Center _backgroundGraphics() {
    Color textColor = context.isDarkMode
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
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
    return Flexible(
      flex: 6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.5,
              child: CircularProgressIndicator(color: context.profitCardColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Fetching Your Transacts',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget TextLink({
    required String text,
    required Uri link,
    Color? color,
    TextAlign? textAlign,
  }) {
    return TextButton(
      onPressed: () {
        launchTheUrl(link);
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(5),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
        textAlign: textAlign,
      ),
    );
  }
}
