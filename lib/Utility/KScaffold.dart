// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

import 'commons.dart';

// ignore: must_be_immutable
class KScaffold extends StatefulWidget {
  PreferredSizeWidget? appBar;
  final Widget body;
  FloatingActionButtonLocation? floatingActionButtonLocation;
  FloatingActionButtonAnimator? floatingActionButtonAnimator;
  Widget? floatingActionButton;
  bool? isLoading = false;
  KScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.isLoading,
    this.floatingActionButtonAnimator,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  State<KScaffold> createState() => _KScaffoldState();
}

class _KScaffoldState extends State<KScaffold> {
  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            appBar: widget.appBar,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // alignment: Alignment.topCenter,
              children: [
                ValueListenableBuilder(
                  valueListenable: ConnectionConfig.hasInternet,
                  builder: (context, bool hasInternet, child) => AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: hasInternet
                        ? Container(width: double.infinity)
                        : Container(
                            color: isDark ? Dark.lossCard : Light.lossCard,
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                            child: SafeArea(
                              bottom: false,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.signal_wifi_off_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  width10,
                                  Text(
                                    "No Connection",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                Expanded(child: widget.body),
              ],
            ),
            floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
            floatingActionButtonLocation: widget.floatingActionButtonLocation,
            floatingActionButton: widget.floatingActionButton,
          ),
          FullScreenLoading(isLoading: widget.isLoading),
        ],
      ),
    );
  }

  AnimatedSwitcher FullScreenLoading({bool? isLoading = false}) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
      child: isLoading ?? false
          ? Container(
              height: double.maxFinite,
              width: double.maxFinite,
              color: isDark
                  ? Colors.black.withOpacity(.8)
                  : Light.card.withOpacity(.8),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: kRadius(100),
                    color: isDark ? Dark.card : Light.card,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              // value: 2,
                              strokeWidth: 3,
                              color: isDark ? Dark.primary : Light.primary,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Text(
                              "Please Wait ...",
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
