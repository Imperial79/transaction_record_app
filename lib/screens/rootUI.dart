import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/screens/Book%20Screens/newBookUI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUi.dart';

class RootUI extends StatefulWidget {
  const RootUI({Key? key}) : super(key: key);

  @override
  State<RootUI> createState() => _RootUIState();
}

class _RootUIState extends State<RootUI> {
  int activeTab = 0;
  late PageController _pageController;
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: activeTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      activeTab = index;
    });
  }

  List<Widget> _pages = [
    HomeUi(),
    NewBookUI(),
  ];

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      // body: PageTransitionSwitcher(
      //   duration: Duration(milliseconds: 200),
      //   transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
      //     return FadeThroughTransition(
      //       animation: primaryAnimation,
      //       secondaryAnimation: secondaryAnimation,
      //       child: child,
      //     );
      //   },
      //   child: _pages[activeTab],
      // ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return PageStorage(
            child: _pages[index],
            bucket: _pageStorageBucket,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeTab,
        selectedItemColor: isDark ? kProfitColorAccent : kProfitColor,
        unselectedItemColor: isDark ? Colors.grey : Colors.grey.shade300,
        onTap: (value) {
          _pageController.animateToPage(value,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create_new_folder),
            label: 'New Book',
          ),
        ],
      ),
    );
  }
}
