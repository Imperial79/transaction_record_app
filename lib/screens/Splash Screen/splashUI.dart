import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../Utility/constants.dart';

class SplashUI extends StatefulWidget {
  const SplashUI({Key? key}) : super(key: key);

  @override
  State<SplashUI> createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await Constants.getUserDetailsFromPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Lottie.asset("lib/assets/loading/splash_loading.json"),
        ),
      ),
    );
  }
}
