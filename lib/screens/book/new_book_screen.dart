import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/repositories/book_repository.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import '../../repositories/auth_repository.dart';
import '../../utility/commons.dart';
import '../../utility/newColors.dart';

class NewBookScreen extends ConsumerStatefulWidget {
  const NewBookScreen({super.key});
  @override
  ConsumerState<NewBookScreen> createState() => _NewBookScreenState();
}

class _NewBookScreenState extends ConsumerState<NewBookScreen> {
  final Map<String, String> bookTypeMap = {
    "Regular": "Daily transaction audits with income and expense tracking.",
    "Due": "Track debt/credit against a specific target goal.",
    "Savings": "Accumulate wealth and track savings progress over time.",
  };

  final isLoading = ValueNotifier(false);
  final _targetAmount = TextEditingController();
  final _bookTitle = TextEditingController(
    text: DateFormat('MMMM, yyyy').format(DateTime.now()),
  );
  final _bookDescription = TextEditingController();
  String selectedBookType = 'regular';

  void _createBook(String uid) async {
    if (_bookTitle.text.isEmpty) {
      KSnackbar(context, content: "Please enter a book name", isDanger: true);
      return;
    }

    FocusScope.of(context).unfocus();
    try {
      isLoading.value = true;
      final now = DateTime.now();
      String displayDate = DateFormat.yMMMMd().format(now);
      String displayTime = DateFormat.jm().format(now);

      BookModel newBook = BookModel(
        bookId: "$now",
        bookName: _bookTitle.text,
        bookDescription: _bookDescription.text,
        date: displayDate,
        expense: 0.0,
        income: 0.0,
        time: displayTime,
        type: selectedBookType,
        uid: uid,
        targetAmount: selectedBookType == "due"
            ? (double.tryParse(_targetAmount.text) ?? 0)
            : 0,
        createdAt: "$now",
        users: [],
      );

      final res = await ref
          .read(bookrepositories)
          .createBook(bookId: "$now", data: newBook.toMap());
      if (res && context.mounted) {
        KSnackbar(context, content: 'Book created successfully!');
        ref
            .read(pageControllerProvider)
            .animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
        _bookDescription.clear();
        _targetAmount.clear();
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Creation failed", isDanger: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _bookTitle.dispose();
    _bookDescription.dispose();
    _targetAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: context.textColor.lighten(0.1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => ref
                        .read(pageControllerProvider)
                        .animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  Text(
                    "CREATE NEW BOOK",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: context.fadeTextColor,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BOOK NAME",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: context.fadeTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bookTitle,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Title...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: context.textColor.lighten(0.2),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _bookTitle.text = DateFormat(
                              'MMMM, yyyy',
                            ).format(DateTime.now()),
                          ),
                          icon: const Icon(Icons.auto_awesome),
                          tooltip: "Magic Title",
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _inputLabel("DESCRIPTION"),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bookDescription,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Add some context...",
                        filled: true,
                        fillColor: context.textColor.lighten(0.05),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _inputLabel("CHOOSE CATEGORY"),
                    const SizedBox(height: 16),
                    MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: bookTypeMap.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        String key = bookTypeMap.keys.toList()[index];
                        return _typeCard(
                          title: key.toUpperCase(),
                          desc: bookTypeMap.values.toList()[index],
                          type: key.toLowerCase(),
                          icon: _getIcon(key.toLowerCase()),
                        );
                      },
                    ),
                    if (selectedBookType == "due") ...[
                      const SizedBox(height: 32),
                      _inputLabel("TARGET AMOUNT"),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _targetAmount,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          prefixText: "₹ ",
                          filled: true,
                          fillColor: context.textColor.lighten(0.05),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: InkWell(
                onTap: () {
                  if (user != null) _createBook(user.uid);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: context.textColor),
                  child: Text(
                    "INITIALIZE BOOK",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.scaffoldColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: context.fadeTextColor,
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type == 'regular') return Icons.receipt_long;
    if (type == 'due') return Icons.timer;
    return Icons.savings;
  }

  Widget _typeCard({
    required String title,
    required String desc,
    required String type,
    required IconData icon,
  }) {
    final isActive = selectedBookType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedBookType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? context.textColor : Colors.transparent,
          border: Border.all(
            color: isActive
                ? context.textColor
                : context.textColor.lighten(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? context.scaffoldColor : context.textColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isActive ? context.scaffoldColor : context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(
                fontSize: 9,
                height: 1.4,
                color: isActive
                    ? context.scaffoldColor.lighten(0.7)
                    : context.fadeTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
