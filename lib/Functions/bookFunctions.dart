//--------- DELETE BOOK--------------------------->
import 'package:flutter/material.dart';

import '../services/database.dart';
import 'navigatorFns.dart';

class BookMethods {
  static Future<void> deleteBook(
    BuildContext context, {
    required String bookName,
    required String bookId,
  }) async {
    // final bookName = widget.snap['bookName'];
    // setState(() {
    //   _isLoading = true;
    // });

    try {
      await DatabaseMethods().deleteBookWithCollections(bookId);
      // setState(() {
      //   _isLoading = false;
      // });
      ShowSnackBar(
        context,
        '"$bookName"' + ' book has been deleted',
      );
    } catch (e) {
      // setState(() {
      //   _isLoading = false;
      // });
      ShowSnackBar(
        context,
        'Something went wrong. Please try again after sometime',
      );
    }

    Navigator.pop(context);
  }
}
