import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:transaction_record_app/repositories/system_repository.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../repositories/auth_repository.dart';
import '../../utility/commons.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> updateAccountDetails(String uid) async {
    if (nameController.text.isEmpty) {
      KSnackbar(context, content: 'Please enter your name', isDanger: true);
      return;
    }

    try {
      isLoading.value = true;
      await DatabaseMethods().updateAccountDetails(uid, {
        'name': nameController.text,
      });

      final userBox = await Hive.openBox("USERBOX");
      final userMap = userBox.get("userData");
      if (userMap != null) {
        userMap['userDisplayName'] = nameController.text;
        userBox.put('userData', userMap);
      }

      ref
          .read(userProvider.notifier)
          .update((state) => state!.copyWith(name: nameController.text));
      KSnackbar(context, content: "Name Updated Successfully");
    } catch (e) {
      KSnackbar(context, content: "Update failed", isDanger: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) return const SizedBox();

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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  Text(
                    "ACCOUNT PROFILE",
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
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.textColor,
                            width: 1,
                          ),
                        ),
                        child: Image.network(
                          user.imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        "@${user.username.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: context.fadeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    _profileInput(
                      label: "DISPLAY NAME",
                      controller: nameController,
                    ),
                    const SizedBox(height: 24),
                    _profileInput(
                      label: "EMAIL ADDRESS",
                      controller: emailController,
                      enabled: false,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      "SYSTEM THEME",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: context.fadeTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _themeBtn("Light"),
                        const SizedBox(width: 12),
                        _themeBtn("Dark"),
                        const SizedBox(width: 12),
                        _themeBtn("System"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: InkWell(
                onTap: () => updateAccountDetails(user.uid),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: context.textColor),
                  child: Text(
                    "UPDATE ACCOUNT SETTINGS",
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

  Widget _profileInput({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: context.fadeTextColor,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: enabled ? context.textColor : context.fadeTextColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.textColor.lighten(enabled ? 0.05 : 0.02),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: context.textColor.lighten(0.1)),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.textColor, width: 1.5),
              borderRadius: BorderRadius.zero,
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.textColor.lighten(0.05)),
              borderRadius: BorderRadius.zero,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _themeBtn(String theme) {
    return Expanded(
      child: Consumer(
        builder: (context, ref, _) {
          final notifier = ref.watch(themeProvider.notifier);
          final bool isActive = notifier.themeString == theme;

          return InkWell(
            onTap: () => notifier.setTheme(theme),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isActive ? context.textColor : Colors.transparent,
                border: Border.all(
                  color: isActive
                      ? context.textColor
                      : context.textColor.lighten(0.1),
                ),
              ),
              child: Text(
                theme.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? context.scaffoldColor : context.textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
