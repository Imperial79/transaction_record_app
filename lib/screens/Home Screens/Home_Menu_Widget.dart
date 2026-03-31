// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/Helper/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Account Screen/accountUI.dart';
import 'package:transaction_record_app/Repository/book_repository.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import '../../Utility/commons.dart';

class Home_Menu_Widget extends ConsumerStatefulWidget {
  final ValueNotifier<bool>? isLoading;
  const Home_Menu_Widget({super.key, this.isLoading});

  @override
  ConsumerState<Home_Menu_Widget> createState() => _HomeMenuUIState();
}

class _HomeMenuUIState extends ConsumerState<Home_Menu_Widget> {
  Future<void> _signOut() async {
    try {
      if (widget.isLoading != null) {
        widget.isLoading!.value = true;
      }

      final res = await ref.read(authRepository).signOut();
      if (res && context.mounted) {
        ref.read(userProvider.notifier).state = null;
        // NavPushReplacement(context, const LoginUI());
        context.pushReplacement("/login");
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Something went wrong!", isDanger: true);
      }
    } finally {
      if (mounted && widget.isLoading != null) {
        widget.isLoading!.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final books = ref.watch(bookListProvider);

    // Calculate Summary
    double totalNet = books.fold(
      0.0,
      (sum, book) => sum + (book.income - book.expense),
    );
    double totalIncome = books.fold(0.0, (sum, book) => sum + book.income);
    double totalExpense = books.fold(0.0, (sum, book) => sum + book.expense);

    return Container(
      decoration: BoxDecoration(
        borderRadius: kRadius(28),
        color: context.cardColor,
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.fadeTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hello, ${user?.name.split(" ").first ?? "User"}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: context.primaryColor.withAlpha(30),
                child: Icon(Icons.bolt, size: 14, color: context.primaryColor),
              ),
            ],
          ),
          height20,

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primaryColor,
                  context.primaryColor.darken(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: kRadius(24),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withAlpha(60),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                height5,
                Text(
                  '₹${kMoneyFormat(totalNet)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                height15,
                Row(
                  children: [
                    _miniStat(
                      label: 'Income',
                      amount: totalIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: Colors.greenAccent,
                    ),
                    const Spacer(),
                    _miniStat(
                      label: 'Expense',
                      amount: totalExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          kHeight(25),

          // Actions Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HomeMenuBtn(
                label: 'Add Book',
                icon: Icons.add_rounded,
                onTap: () {
                  ref
                      .read(pageControllerProvider)
                      .animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                },
                btnColor: context.primaryColor.withAlpha(20),
                contentColor: context.primaryColor,
              ),
              HomeMenuBtn(
                label: 'Account',
                icon: Icons.person_outline_rounded,
                onTap: () => navPush(context, const AccountUI()),
                btnColor: context.fadeTextColor.withAlpha(20),
                contentColor: context.colorScheme.onSurface,
              ),
              HomeMenuBtn(
                label: 'Logout',
                icon: Icons.logout_rounded,
                onTap: () => _confirmSignOut(),
                btnColor: context.lossColor.withAlpha(20),
                contentColor: context.lossColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: kRadius(24)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.fadeTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.lossColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: kRadius(8),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        width10,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${kMoneyFormat(amount)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget HomeMenuBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? btnColor,
    Color? contentColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: kRadius(20),
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: kRadius(20),
              ),
              child: Icon(icon, color: contentColor, size: 26),
            ),
          ),
          kHeight(8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
