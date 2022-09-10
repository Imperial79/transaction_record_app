import 'dart:ui';

import 'package:flutter/material.dart';

class HomeMenuUI extends StatefulWidget {
  const HomeMenuUI({Key? key}) : super(key: key);

  @override
  State<HomeMenuUI> createState() => _HomeMenuUIState();
}

class _HomeMenuUIState extends State<HomeMenuUI> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.grey.withOpacity(0.7),
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.close),
              ),
            ),
            Text(
              'Settings',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
