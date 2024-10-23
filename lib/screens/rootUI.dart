import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Repository/system_repository.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/main.dart';
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

  _changeTheme(String themeMode) async {
    if (themeMode == 'dark') {
      ref.read(themeProvider.notifier).state = "light";
    } else if (themeMode == 'light') {
      ref.read(themeProvider.notifier).state = "system";
    } else {
      ref.read(themeProvider.notifier).state = "dark";
    }

    var hiveBox = Hive.box("hiveBox");

    hiveBox.put("theme", themeMode);
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final themeMode = ref.watch(themeProvider);
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
                            context,
                            index: 0,
                            label: 'Home',
                          ),
                          _changeToPageButton(
                            context,
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
                      _changeTheme(themeMode);
                    },
                    icon: Icon(
                      themeMode == "dark"
                          ? Icons.light_mode
                          : themeMode == "light"
                              ? Icons.auto_awesome
                              : Icons.dark_mode,
                    ),
                  ),
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
                                  ? const Icon(Icons.notifications)
                                  : CircleAvatar(
                                      radius: 12,
                                      backgroundColor: isDark
                                          ? Dark.profitText
                                          : Light.profitText,
                                      foregroundColor:
                                          isDark ? Colors.black : Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                              "${snapshot.data!.docs.length}"),
                                        ),
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
    BuildContext context, {
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
