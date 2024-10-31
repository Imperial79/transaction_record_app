// ignore_for_file: non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import '../../Utility/commons.dart';
import '../../Utility/components.dart';
import '../Login_UI.dart';

class HomeMenuUI extends ConsumerStatefulWidget {
  const HomeMenuUI({super.key});

  @override
  ConsumerState<HomeMenuUI> createState() => _HomeMenuUIState();
}

class _HomeMenuUIState extends ConsumerState<HomeMenuUI> {
  bool isLoading = false;

  _signOut() async {
    try {
      setState(() {
        isLoading = true;
      });

      final res = await ref.read(authRepository).signOut();
      if (res) {
        ref.read(userProvider.notifier).state = null;
        NavPushReplacement(context, const LoginUI());
      }
    } catch (e) {
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    final user = ref.watch(userProvider);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 5, bottom: 5),
              child: Center(
                child: Text(
                  'SETTINGS',
                  style: TextStyle(
                    letterSpacing: 7,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Dark.scaffold : Light.scaffold,
                borderRadius: kRadius(20),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HomeMenuBtn(
                        isDark,
                        label: 'Account',
                        borderColor: isDark ? Dark.fadeText : Light.fadeText,
                        child: GestureDetector(
                          onTap: () {
                            navPush(context, const AccountUI());
                          },
                          child: ClipRRect(
                            borderRadius: kRadius(20),
                            child: CachedNetworkImage(
                              imageUrl: user?.imgUrl ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        btnColor: const Color.fromARGB(255, 210, 235, 255),
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
                        isDark,
                        label: 'Logout',
                        borderColor:
                            isDark ? Colors.red.shade300 : Colors.red.shade900,
                        child: IconButton(
                          onPressed: () {
                            _signOut();
                          },
                          icon: Icon(
                            Icons.logout,
                            color: isDark ? Colors.white : Colors.red.shade900,
                          ),
                        ),
                        btnColor: isDark
                            ? Colors.red.shade900
                            : const Color.fromARGB(255, 255, 208, 205),
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
    bool isDark, {
    required String label,
    required Widget child,
    Color? btnColor,
    Color? borderColor,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            width: 50,
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
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}