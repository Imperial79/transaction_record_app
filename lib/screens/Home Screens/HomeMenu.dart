// ignore_for_file: non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Helper/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Account Screen/accountUI.dart';
import '../../Utility/commons.dart';
import '../../Utility/components.dart';

class HomeMenuUI extends ConsumerStatefulWidget {
  final ValueNotifier<bool>? isLoading;
  const HomeMenuUI({super.key, this.isLoading});

  @override
  ConsumerState<HomeMenuUI> createState() => _HomeMenuUIState();
}

class _HomeMenuUIState extends ConsumerState<HomeMenuUI> {
  Future<void> _signOut() async {
    try {
      if (widget.isLoading != null) {
        widget.isLoading!.value = true;
      }

      final res = await ref.read(authRepository).signOut();
      if (res) {
        ref.read(userProvider.notifier).state = null;
        // NavPushReplacement(context, const LoginUI());
        context.pushReplacement("/login");
      }
    } catch (e) {
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    } finally {
      if (mounted && widget.isLoading != null) {
        widget.isLoading!.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    final user = ref.watch(userProvider);
    return Container(
      decoration: BoxDecoration(
        borderRadius: kRadius(20),
        color: context.cardColor,
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kLabel('Actions', fontSize: 20, top: 0, bottom: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              HomeMenuBtn(
                label: 'Account',
                borderColor: context.fadeTextColor,
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
              HomeMenuBtn(
                label: 'Logout',
                borderColor: context.isDarkMode
                    ? Colors.red.shade300
                    : Colors.red.shade900,
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                          'Are you sure you want to sign out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _signOut();
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(color: context.lossColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.logout,
                    color: context.isDarkMode
                        ? Colors.white
                        : Colors.red.shade900,
                  ),
                ),
                btnColor: context.isDarkMode
                    ? Colors.red.shade900
                    : const Color.fromARGB(255, 255, 208, 205),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget HomeMenuBtn({
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
              color: context.colorScheme.onSurface,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
