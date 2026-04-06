// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/KLoading.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

// ignore: must_be_immutable
class KScaffold extends StatelessWidget {
  PreferredSizeWidget? appBar;
  final Widget body;
  FloatingActionButtonLocation? floatingActionButtonLocation;
  FloatingActionButtonAnimator? floatingActionButtonAnimator;
  Widget? floatingActionButton;
  ValueNotifier<bool>? isLoading;
  KScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.isLoading,
    this.floatingActionButtonAnimator,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: isLoading ?? ValueNotifier(false),
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Scaffold(
                appBar: appBar,
                body: body,
                floatingActionButtonAnimator: floatingActionButtonAnimator,
                floatingActionButtonLocation: floatingActionButtonLocation,
                floatingActionButton: floatingActionButton,
              ),
              _fullScreenLoading(context, isLoading: value),
            ],
          );
        },
      ),
    );
  }

  AnimatedSwitcher _fullScreenLoading(
    BuildContext context, {
    required bool isLoading,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      child: isLoading
          ? Container(
              height: double.maxFinite,
              width: double.maxFinite,
              color: context.scaffoldColor.withAlpha(200),
              child: KLoading.fullPage(context, label: "PLEASE WAIT..."),
            )
          : const SizedBox(),
    );
  }
}
