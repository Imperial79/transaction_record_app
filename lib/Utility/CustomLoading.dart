import 'dart:async';

import 'package:flutter/material.dart';

class CustomLoading extends StatefulWidget {
  const CustomLoading({super.key});

  @override
  State<CustomLoading> createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading> {
  late Timer timer;
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    startLoading();
  }

  Future<void> startLoading() async {
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        if (currentIndex == 2) {
          currentIndex = 0;
        } else {
          currentIndex += 1;
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: AnimatedScale(
            duration: Duration(milliseconds: 200),
            scale: currentIndex == index ? 2 : 1,
            child: CircleAvatar(
              radius: 2,
              backgroundColor:
                  currentIndex == index ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
