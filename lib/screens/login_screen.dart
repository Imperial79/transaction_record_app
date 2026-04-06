import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:upgrader/upgrader.dart';
import '../Utility/commons.dart';
import 'package:transaction_record_app/Utility/KLoading.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final Uri _privacyPolicyUrl = Uri.parse(
    'https://www.freeprivacypolicy.com/live/d6175538-7c18-42f4-989e-2c6351204f4b',
  );
  final isLoading = ValueNotifier(false);

  Future<void> _googleSignIn() async {
    try {
      isLoading.value = true;
      final user = await ref.read(authrepositories).signIn();
      if (user != null) {
        ref.read(userProvider.notifier).state = user;
        if (context.mounted) context.pushReplacement('/root');
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Authentication failed", isDanger: true);
      }
    } finally {
      if (mounted) isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: KScaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                _backgroundGraphics(),
                ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (context, loading, child) {
                    if (loading) return _loadingScreen();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'TRANSACT',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -3,
                                  height: 0.9,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'PERSONAL MONEY MANAGER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  color: context.textColor.lighten(0.4),
                                ),
                              ),
                              const SizedBox(height: 48),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: context.profitColor,
                                  ),
                                ),
                                child: Text(
                                  '#SECURE & PRIVATE',
                                  style: TextStyle(
                                    color: context.profitColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.profitColor.lighten(0.05),
                                border: Border.all(
                                  color: context.profitColor.lighten(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.cloudCheck,
                                    color: context.profitColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'AUTOMATIC CLOUD SYNC ENABLED',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10,
                                        letterSpacing: 1,
                                        color: context.profitColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            KButton.full(
                              context,
                              label: "CONTINUE WITH GOOGLE",
                              icon: LucideIcons.circleUser,
                              onPressed: _googleSignIn,
                            ),
                            const SizedBox(height: 24),
                            Text.rich(
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: context.fadeTextColor,
                                height: 1.6,
                                letterSpacing: 0.5,
                              ),
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "BY SIGNING IN, YOU AGREE WITH OUR ",
                                  ),
                                  TextSpan(
                                    text: "TERMS ",
                                    style: TextStyle(
                                      color: context.textColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const TextSpan(text: "& "),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async =>
                                          await launchTheUrl(_privacyPolicyUrl),
                                    text: "PRIVACY POLICY.",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: context.textColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _backgroundGraphics() {
    return Positioned(
      right: -100,
      top: -50,
      child: Text(
        "₹",
        style: TextStyle(
          fontSize: 600,
          height: 1,
          color: context.textColor.lighten(context.isDarkMode ? 0.03 : 0.015),
        ),
      ),
    );
  }

  Widget _loadingScreen() {
    return KLoading.fullPage(context, label: "PLEASE WAIT...");
  }
}
