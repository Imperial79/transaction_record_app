// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/components.dart';

// ignore: must_be_immutable
class KScaffold extends StatefulWidget {
  PreferredSizeWidget? appBar;
  final Widget body;
  FloatingActionButtonLocation? floatingActionButtonLocation;
  FloatingActionButtonAnimator? floatingActionButtonAnimator;
  Widget? floatingActionButton;
  bool? isLoading = false;
  KScaffold(
      {Key? key,
      this.appBar,
      required this.body,
      this.isLoading,
      this.floatingActionButtonAnimator,
      this.floatingActionButtonLocation,
      this.floatingActionButton})
      : super(key: key);

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
          body: widget.body,
          floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
          floatingActionButtonLocation: widget.floatingActionButtonLocation,
          floatingActionButton: widget.floatingActionButton,
        ),
        FullScreenLoading(isLoading: widget.isLoading),
      ],
    );
  }
}
