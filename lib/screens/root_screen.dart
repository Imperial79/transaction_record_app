import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/screens/book/new_book_screen.dart';
import 'package:transaction_record_app/screens/home/home_screen.dart';
import 'package:transaction_record_app/screens/notification/notifications_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'package:transaction_record_app/utility/constants.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});
  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  final List<Widget> _pages = [const HomeScreen(), const NewBookScreen()];

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const Scaffold();

    final activePage = ref.watch(homePageProvider);

    return UpgradeAlert(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: context.textColor.lighten(0.1)),
                ),
                child: Row(
                  children: [
                    _tabBtn(
                      index: 0,
                      label: "BOOKS",
                      isActive: activePage == 0,
                    ),
                    const SizedBox(width: 8),
                    _tabBtn(index: 1, label: "NEW", isActive: activePage == 1),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          navPush(context, const NotificationsScreen()),
                      icon: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('requests')
                            .where('users', arrayContains: user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final count = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return count > 0
                              ? Badge(
                                  label: Text("$count"),
                                  child: const Icon(LucideIcons.bellRing),
                                )
                              : const Icon(LucideIcons.bell);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: ref.watch(pageControllerProvider),
                  itemCount: _pages.length,
                  onPageChanged: (val) =>
                      ref.read(homePageProvider.notifier).state = val,
                  itemBuilder: (context, index) => PageStorage(
                    bucket: _pageStorageBucket,
                    child: _pages[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBtn({
    required int index,
    required String label,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => ref
          .read(pageControllerProvider)
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: APP_PADDING, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? context.textColor : Colors.transparent,
          border: Border.all(
            color: isActive ? context.textColor : Colors.transparent,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isActive ? context.scaffoldColor : context.fadeTextColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
