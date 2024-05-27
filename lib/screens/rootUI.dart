import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/Utility/sdp.dart';
import 'package:transaction_record_app/main.dart';
import 'package:transaction_record_app/screens/Book%20Screens/newBookUI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUI.dart';
import 'package:transaction_record_app/screens/Notification%20Screen/notificationsUI.dart';
import 'package:transaction_record_app/services/user.dart';

import 'migrateUI.dart';

ValueNotifier<PageController> pageControllerGlobal =
    ValueNotifier(PageController(initialPage: 0));

ValueNotifier<int> activeTabGlobal = ValueNotifier(0);

class RootUI extends StatefulWidget {
  const RootUI({Key? key}) : super(key: key);

  @override
  State<RootUI> createState() => _RootUIState();
}

class _RootUIState extends State<RootUI> {
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await Constants.getUserDetailsFromPreference()
        .then((value) => setState(() {}));

    QActions.init(context);
  }

  void _onPageChanged(int index) {
    setState(() {
      activeTabGlobal.value = index;
    });
  }

  List<Widget> _pages = [
    HomeUi(),
    NewBookUI(),
  ];

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
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
                    setState(() {
                      if (themeMode.value == 'dark') {
                        themeMode.value = 'light';
                      } else if (themeMode.value == 'light') {
                        themeMode.value = 'system';
                      } else {
                        themeMode.value = 'dark';
                      }
                    });
                  },
                  icon: Icon(themeMode.value == "dark"
                      ? Icons.light_mode
                      : themeMode.value == "light"
                          ? Icons.auto_awesome
                          : Icons.dark_mode),
                ),
                IconButton(
                  onPressed: () {
                    NavPush(context, NotificationsUI());
                  },
                  icon: StreamBuilder<dynamic>(
                    stream: FirebaseRefs.requestRef
                        .where('users', arrayContains: globalUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 600),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: !snapshot.hasData
                            ? Transform.scale(
                                scale: .5,
                                child: CircularProgressIndicator(),
                              )
                            : snapshot.data!.docs.length == 0
                                ? Icon(Icons.notifications)
                                : CircleAvatar(
                                    radius: sdp(context, 10),
                                    backgroundColor: isDark
                                        ? Dark.profitText
                                        : Light.profitText,
                                    foregroundColor:
                                        isDark ? Colors.black : Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
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
              child: ValueListenableBuilder(
                  valueListenable: pageControllerGlobal,
                  builder: (context, PageController _pageController, child) {
                    return PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return PageStorage(
                          child: _pages[index],
                          bucket: _pageStorageBucket,
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  TextButton _changeToPageButton(
    BuildContext context, {
    required int index,
    required String label,
  }) {
    bool isActive = activeTabGlobal.value == index;
    return TextButton(
      onPressed: () {
        pageControllerGlobal.value.animateToPage(index,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: sdp(context, 15),
          color: isActive
              ? isDark
                  ? Colors.white
                  : Colors.black
              : Colors.grey,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}
