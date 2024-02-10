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
        content: '"$bookName"' + ' book has been deleted',
      );
    } catch (e) {
      // setState(() {
      //   _isLoading = false;
      // });
      ShowSnackBar(
        context,
        content: 'Something went wrong. Please try again after sometime',
        isDanger: true,
      );
    }

    Navigator.pop(context);
  }
}
