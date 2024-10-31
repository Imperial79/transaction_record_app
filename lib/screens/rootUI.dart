import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Book%20Screens/New_Book_UI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/Home_UI.dart';
import 'package:transaction_record_app/screens/Notification%20Screen/notificationsUI.dart';

class RootUI extends ConsumerStatefulWidget {
  const RootUI({super.key});

  @override
  ConsumerState<RootUI> createState() => _RootUIState();
}

class _RootUIState extends ConsumerState<RootUI> {
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  final List<Widget> _pages = [
    Home_UI(),
    const New_Book_UI(),
  ];

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    if (user != null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          _changeToPageButton(
                            isDark,
                            index: 0,
                            label: 'Home',
                          ),
                          _changeToPageButton(
                            isDark,
                            index: 1,
                            label: 'New Book',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // IconButton(
                  //     onPressed: () {
                  //       NavPush(context, MigrateUI());
                  //     },
                  //     icon: Icon(Icons.refresh)),

                  IconButton(
                    onPressed: () {
                      navPush(context, const NotificationsUI());
                    },
                    icon: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseRefs.requestRef
                          .where('users', arrayContains: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          child: !snapshot.hasData
                              ? Transform.scale(
                                  scale: .5,
                                  child: const CircularProgressIndicator(),
                                )
                              : snapshot.data!.docs.isEmpty
                                  ? const Icon(Icons.notifications_none_rounded)
                                  : Badge(
                                      label:
                                          Text("${snapshot.data!.docs.length}"),
                                      child: Icon(
                                        Icons.notifications_active,
                                        color: isDark
                                            ? Dark.profitText
                                            : Light.profitText,
                                      ),
                                    ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: ref.watch(pageControllerProvider),
                  itemCount: _pages.length,
                  onPageChanged: (value) {
                    ref.read(homePageProvider.notifier).state = value;
                  },
                  itemBuilder: (context, index) {
                    return PageStorage(
                      bucket: _pageStorageBucket,
                      child: _pages[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold();
  }

  Widget _changeToPageButton(
    bool isDark, {
    required int index,
    required String label,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final activePage = ref.watch(homePageProvider);
        bool isActive = activePage == index;
        return TextButton(
          onPressed: () {
            ref.watch(pageControllerProvider).animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
          },
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              color: isActive
                  ? isDark
                      ? Colors.white
                      : Colors.black
                  : Colors.grey,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}
