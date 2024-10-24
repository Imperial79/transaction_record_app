import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

class SplashUI extends ConsumerStatefulWidget {
  const SplashUI({super.key});

  @override
  ConsumerState<SplashUI> createState() => _SplashUIState();
}

class _SplashUIState extends ConsumerState<SplashUI> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "T₹ansact",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 50,
                  height: 1,
                  color: isDark ? Dark.text : Light.text,
                ),
              ),
              Text(
                "Record",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 50,
                  height: 1,
                  color: isDark ? Dark.text : Light.text,
                ),
              ),
              Text(
                "₹",
                style: TextStyle(
                  fontSize: 200,
                  height: 1,
                  fontFamily: "",
                  color: isDark ? Colors.cyanAccent : Colors.cyan.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
