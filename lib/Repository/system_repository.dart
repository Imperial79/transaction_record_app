import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<String>(
  (ref) => "system",
);
