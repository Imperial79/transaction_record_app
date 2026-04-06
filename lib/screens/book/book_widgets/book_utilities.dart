import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class BookScrollHelper {
  final ScrollController controller;
  final StateProvider<bool> showStatsProvider;
  final StateProvider<int> countProvider;
  final WidgetRef ref;

  BookScrollHelper({
    required this.controller,
    required this.showStatsProvider,
    required this.countProvider,
    required this.ref,
  });

  void addListener() {
    controller.addListener(_scrollListener);
  }

  void removeListener() {
    controller.removeListener(_scrollListener);
  }

  void _scrollListener() {
    // Show/hide stats based on scroll direction
    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (ref.read(showStatsProvider)) {
        ref.read(showStatsProvider.notifier).state = false;
      }
    } else if (controller.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!ref.read(showStatsProvider)) {
        ref.read(showStatsProvider.notifier).state = true;
      }
    }

    // Pagination logic
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      ref.read(countProvider.notifier).state += 10;
    }
  }
}
