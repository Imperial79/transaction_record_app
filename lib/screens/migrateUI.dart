import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import '../Utility/newColors.dart';

class MigrateUI extends StatefulWidget {
  const MigrateUI({Key? key}) : super(key: key);

  @override
  State<MigrateUI> createState() => _MigrateUIState();
}

class _MigrateUIState extends State<MigrateUI> {
  void fetch() async {
    await FirebaseFirestore.instance.collection("transactBooks").get().then(
      (value) async {
        value.docs.forEach(
          (book) async {
            final bookData = book.data();
            final bookId = bookData['bookId'];
            final bookName = bookData['bookName'];
            await FirebaseFirestore.instance
                .collection('transactBooks')
                .doc(bookId)
                .collection('transacts')
                .get()
                .then(
              (value) async {
                double income = 0.0;
                double expense = 0.0;
                value.docs.forEach(
                  (transact) {
                    bool isIncome = transact.data()['type'] == "Income";
                    final amount = transact.data()['amount'];
                    if (isIncome) {
                      income += double.parse(amount.toString());
                    } else {
                      expense += double.parse(amount.toString());
                    }
                  },
                );

                await FirebaseFirestore.instance
                    .collection('transactBooks')
                    .doc(bookId)
                    .set(
                      BookModel(
                        bookId: bookId,
                        bookName: bookName,
                        bookDescription: bookData['bookDescription'],
                        date: bookData['date'],
                        expense: expense,
                        income: income,
                        targetAmount: bookData["targetAmount"],
                        time: bookData['time'],
                        type: bookData['type'],
                        uid: bookData['uid'],
                        createdAt: bookId,
                        users: bookData['users'],
                      ).toMap(),
                    );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              fetch();
            },
            child: Text('migrate'),
          ),
        ),
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     ElevatedButton(
        //       onPressed: () {
        //         fetch();
        //       },
        //       child: Text('migrate'),
        //     ),
        //     Flexible(
        //       child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        //         stream: FirebaseFirestore.instance
        //             .collection('transactBooks')
        //             .where('uid', isEqualTo: FirebaseRefs.myRef)
        //             .snapshots(),
        //         builder: (context, snapshot) {
        //           return ListView.builder(
        //             itemCount: snapshot.data!.docs.length,
        //             itemBuilder: (context, index) =>
        //                 Text(snapshot.data!.docs[index].data()['bookName']),
        //           );
        //         },
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
