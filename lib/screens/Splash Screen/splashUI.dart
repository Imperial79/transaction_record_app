import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Utility/CustomLoading.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "₹",
                        style: TextStyle(
                          fontFamily: "Serif",
                          fontSize: 500,
                          color:
                              isDark
                                  ? Colors.white.lighten(.1)
                                  : Colors.black.lighten(.05),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 2,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        child: Text(
                          "Transact",
                          style: TextStyle(
                            fontFamily: "Serif",
                            fontSize: 80,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomLoading(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
