import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Repository/book_repository.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:wave_divider/wave_divider.dart';

import '../../Repository/auth_repository.dart';
import '../../Utility/commons.dart';

class New_Book_UI extends ConsumerStatefulWidget {
  const New_Book_UI({super.key});

  @override
  ConsumerState<New_Book_UI> createState() => _New_Book_UIState();
}

class _New_Book_UIState extends ConsumerState<New_Book_UI> {
  final Map<String, String> bookTypeMap = {
    "Regular": "Regular book is used for daily transaction audits.",
    "Due":
        "Due book is used for tracking due amount lend to someone or chasing a target amount.",
    "Savings": "Savings book is used for tracking collected/saved amount.",
  };

  final isLoading = ValueNotifier(false);
  final DateTime _selectedDate = DateTime.now();
  final DateTime _selectedTimeStamp = DateTime.now();
  final String _selectedTime = DateFormat()
      .add_jm()
      .format(DateTime.now())
      .toString();

  final _targetAmount = TextEditingController();
  final _bookTitle = TextEditingController(
    text: DateFormat('MMMM, yyyy').format(DateTime.now()),
  );
  final _bookDescription = TextEditingController();
  final dbMethod = DatabaseMethods();

  String selectedBookType = 'regular';

  void _createBook(String uid) async {
    FocusScope.of(context).unfocus();
    try {
      isLoading.value = true;
      if (_bookTitle.text.isNotEmpty) {
        String displayDate = DateFormat.yMMMMd().format(_selectedDate);
        String displayTime = DateFormat()
            .add_jm()
            .format(_selectedTimeStamp)
            .toString();
        BookModel newBook = BookModel(
          bookId: "$_selectedTimeStamp",
          bookName: _bookTitle.text,
          bookDescription: _bookDescription.text,
          date: displayDate,
          expense: 0.0,
          income: 0.0,
          time: displayTime,
          type: selectedBookType,
          uid: uid,
          targetAmount: selectedBookType == "due"
              ? double.parse(_targetAmount.text)
              : 0,
          createdAt: "$_selectedTimeStamp",
          users: [],
        );

        final res = await ref
            .read(bookRepository)
            .createBook(bookId: "$_selectedTimeStamp", data: newBook.toMap());
        if (res && context.mounted) {
          KSnackbar(context, content: 'Book Created');

          await ref.read(pageControllerProvider).animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
        } else if (context.mounted) {
          KSnackbar(context, content: "Something went wrong!", isDanger: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "$e", isDanger: true);
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: KTextfield.title(
                      context,
                      controller: _bookTitle,
                      maxLength: 20,
                      hintText: "Enter Name...",
                      fontSize: 32,
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _bookTitle.text.length >= 20
                          ? context.lossColor.withAlpha(50)
                          : context.fadeTextColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_bookTitle.text.length}/20",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _bookTitle.text.length >= 20
                            ? context.lossColor
                            : context.fadeTextColor,
                      ),
                    ),
                  ),
                ],
              ),

              WaveDivider(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: context.isDarkMode ? Dark.fadeText : Light.fadeText,
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _bookTitle.text = DateFormat(
                        'MMMM, yyyy',
                      ).format(DateTime.now());
                    });
                  },
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: context.profitColor,
                  ),
                  label: Text(
                    "Magic Title",
                    style: TextStyle(
                      color: context.profitColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: context.profitColor.withAlpha(30),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              KTextfield.regular(
                context,
                controller: _bookDescription,
                hintText: 'Add a helpful description...',
                maxLines: 4,
                minLines: 1,
                padding: const EdgeInsets.all(15),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.notes_rounded,
                    color: context.fadeTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  _buildChip(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: DateFormat.yMMMMd().format(_selectedDate),
                  ),
                  const SizedBox(width: 10),
                  _buildChip(
                    context,
                    icon: Icons.access_time_rounded,
                    label: _selectedTime,
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                "BOOK CATEGORY",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),

              MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                itemCount: bookTypeMap.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String key = bookTypeMap.keys.toList()[index];
                  return _bookTypeBtn(
                    isDark,
                    title: key,
                    subTitle: bookTypeMap.values.toList()[index],
                    identifier: key.toLowerCase(),
                    icon: _getIconForType(key.toLowerCase()),
                  );
                },
              ),

              if (selectedBookType == "due") ...[
                const SizedBox(height: 30),
                const Text(
                  "SET TARGET AMOUNT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 15),
                KTextfield.regular(
                  context,
                  controller: _targetAmount,
                  fontSize: 24,
                  hintText: "0.00",
                  keyboardType: TextInputType.number,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Text(
                      "₹",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.profitColor,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: KButton.icon(
            context,
            onPressed: () {
              if (user != null) _createBook(user.uid);
            },
            icon: const Icon(Icons.check_circle_rounded),
            label: "Create Transaction Book",
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.fadeTextColor.withAlpha(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.fadeTextColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.fadeTextColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'regular':
        return Icons.receipt_long_rounded;
      case 'due':
        return Icons.pending_actions_rounded;
      case 'savings':
        return Icons.savings_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Widget _bookTypeBtn(
    bool isDark, {
    required String title,
    required String subTitle,
    required String identifier,
    required IconData icon,
  }) {
    bool isActive = selectedBookType == identifier;
    Color activeColor = identifier == 'due'
        ? Colors.blue
        : identifier == 'savings'
        ? Colors.amber
        : context.profitCardColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBookType = identifier;
          if (identifier != "due") {
            _targetAmount.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isActive
              ? activeColor.withAlpha(isActive ? 30 : 0)
              : context.cardColor,
          border: Border.all(
            width: 2,
            color: isActive ? activeColor : context.fadeTextColor.withAlpha(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor
                    : context.fadeTextColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : context.fadeTextColor,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                color: isActive ? activeColor : context.colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subTitle,
              style: TextStyle(
                fontSize: 11,
                color: context.fadeTextColor,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
