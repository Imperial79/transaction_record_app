// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/Utility/sdp.dart';

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
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          appBar: widget.appBar,
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              widget.body,
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ValueListenableBuilder(
                    valueListenable: ConnectionConfig.hasInternet,
                    builder: (context, bool hasInternet, child) => AnimatedSize(
                      alignment: Alignment.topCenter,
                      duration: Duration(milliseconds: 1000),
                      child: hasInternet
                          ? Container(width: double.infinity)
                          : Container(
                              color: isDark ? Dark.lossCard : Light.lossCard,
                              padding: EdgeInsets.all(5),
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.signal_wifi_off_rounded,
                                    size: sdp(context, 10),
                                  ),
                                  width10,
                                  Text(
                                    "No Connection",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
          floatingActionButtonLocation: widget.floatingActionButtonLocation,
          floatingActionButton: widget.floatingActionButton,
        ),
        FullScreenLoading(isLoading: widget.isLoading),
      ],
    );
  }
}
