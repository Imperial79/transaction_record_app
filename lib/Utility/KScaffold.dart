// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/CustomLoading.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

import 'commons.dart';

// ignore: must_be_immutable
class KScaffold extends StatefulWidget {
  PreferredSizeWidget? appBar;
  final Widget body;
  FloatingActionButtonLocation? floatingActionButtonLocation;
  FloatingActionButtonAnimator? floatingActionButtonAnimator;
  Widget? floatingActionButton;
  bool isLoading;
  KScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.isLoading = false,
    this.floatingActionButtonAnimator,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
  });

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
            body: widget.body,
            floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
            floatingActionButtonLocation: widget.floatingActionButtonLocation,
            floatingActionButton: widget.floatingActionButton,
          ),
          FullScreenLoading(isLoading: widget.isLoading),
        ],
      ),
    );
  }

  AnimatedSwitcher FullScreenLoading({required bool isLoading}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      child:
          isLoading
              ? Container(
                height: double.maxFinite,
                width: double.maxFinite,
                color:
                    isDark ? Colors.black.lighten(.8) : Light.card.lighten(.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomLoading(),
                      height15,
                      Text(
                        "Please Wait ...",
                        style: TextStyle(
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : const SizedBox(),
    );
  }
}
