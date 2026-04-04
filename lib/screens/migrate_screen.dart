import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/models/bookModel.dart';

class MigrateScreen extends StatefulWidget {
  final String id;
  const MigrateScreen({super.key, required this.id});

  @override
  State<MigrateScreen> createState() => _MigrateScreenState();
}

class _MigrateScreenState extends State<MigrateScreen> {
  final isLoading = ValueNotifier(false);

  void _fetchMigration() async {
    try {
      isLoading.value = true;
      final value = await FirebaseFirestore.instance.collection("transactBooks").get();
      for (var book in value.docs) {
        Map<String, dynamic> bookData = book.data();
        final bookId = bookData['bookId'];
        final bookName = bookData['bookName'];
        
        final transacts = await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc(bookId)
            .collection('transacts')
            .get();

        double income = 0.0;
        double expense = 0.0;
        for (var transact in transacts.docs) {
          bool isIncome = transact.data()['type'] == "Income";
          final amount = transact.data()['amount'];
          if (isIncome) {
            income += double.parse(amount.toString());
          } else {
            expense += double.parse(amount.toString());
          }
        }

        await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc(bookId)
            .set(
              BookModel(
                bookId: bookId,
                bookName: bookName,
                bookDescription: bookData['bookDescription'] ?? "",
                date: bookData['date'] ?? "",
                expense: expense,
                income: income,
                targetAmount: bookData["targetAmount"] ?? 0,
                time: bookData['time'] ?? "",
                type: bookData['type'] ?? "regular",
                uid: bookData['uid'] ?? "",
                createdAt: bookId,
                users: bookData['users'] ?? [],
              ).toMap(),
            );
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Migration Complete")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SYSTEM MIGRATION",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: context.fadeTextColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "ID: ${widget.id.toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 48),
              InkWell(
                onTap: _fetchMigration,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  decoration: BoxDecoration(
                    color: context.textColor,
                    border: Border.all(color: context.textColor),
                  ),
                  child: Text(
                    "START MIGRATION",
                    style: TextStyle(
                      color: context.scaffoldColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
