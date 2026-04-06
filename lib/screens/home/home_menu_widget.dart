import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/screens/account/account_screen.dart';
import 'package:transaction_record_app/repositories/book_repository.dart';
import 'package:transaction_record_app/utility/constants.dart';
import '../../utility/commons.dart';

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

      final res = await ref.read(authrepositories).signOut();
      if (res && context.mounted) {
        ref.read(userProvider.notifier).state = null;
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

    double totalNet = books.fold(
      0.0,
      (sum, book) => sum + (book.income - book.expense),
    );
    double totalIncome = books.fold(0.0, (sum, book) => sum + book.income);
    double totalExpense = books.fold(0.0, (sum, book) => sum + book.expense);

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      padding: const EdgeInsets.all(20),
      margin: const .symmetric(vertical: 16),
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
                      'QUICK ACCESS',
                      style: TextStyle(
                        fontSize: 9,
                        color: context.fadeTextColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'HELLO, ${user?.name.split(" ").first.toUpperCase() ?? "USER"}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: context.textColor),
                ),
                child: Icon(
                  LucideIcons.bolt,
                  size: 14,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: context.textColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    color: context.scaffoldColor.lighten(0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        color: totalNet < 0
                            ? context.lossColor
                            : context.scaffoldColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      kMoneyFormat(totalNet.abs()),
                      style: TextStyle(
                        color: totalNet < 0
                            ? context.lossColor
                            : context.scaffoldColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _miniStat(
                      label: 'INCOME',
                      amount: totalIncome,
                      color: context.profitColor,
                    ),
                    const Spacer(),
                    _miniStat(
                      label: 'EXPENSE',
                      amount: totalExpense,
                      color: context.lossColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _menuActionBtn(
                label: 'ADD BOOK',
                icon: LucideIcons.squarePlus,
                onTap: () => ref
                    .read(pageControllerProvider)
                    .animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    ),
              ),
              _menuActionBtn(
                label: 'ACCOUNT',
                icon: LucideIcons.user,
                onTap: () => navPush(context, const AccountScreen()),
              ),
              _menuActionBtn(
                label: 'LOGOUT',
                icon: LucideIcons.logOut,
                onTap: _confirmSignOut,
                isDanger: true,
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
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'SIGN OUT',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: Text(
              'LOGOUT',
              style: TextStyle(
                color: context.lossColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.scaffoldColor.lighten(0.4),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${kMoneyFormat(amount)}',
          style: TextStyle(
            color: context.scaffoldColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _menuActionBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                border: Border.all(color: context.textColor.lighten(0.1)),
              ),
              child: Icon(
                icon,
                color: isDanger ? context.lossColor : context.textColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDanger ? context.lossColor : context.textColor,
              fontSize: 8,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
