import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Repository/system_repository.dart';

import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/services/database.dart';

import '../../Repository/auth_repository.dart';
import '../../Utility/commons.dart';

class AccountUI extends ConsumerStatefulWidget {
  const AccountUI({super.key});

  @override
  ConsumerState<AccountUI> createState() => _AccountUIState();
}

class _AccountUIState extends ConsumerState<AccountUI> {
  //-------------------->
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  //------------------->

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final user = ref.read(userProvider);
      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        setState(() {});
      }
    });
  }

  Future<void> updateAccountDetails(String uid) async {
    isLoading.value = true;
    if (nameController.text.isNotEmpty) {
      Map<String, dynamic> accountMap = {'name': nameController.text};

      await DatabaseMethods().updateAccountDetails(uid, accountMap);

      final userBox = await Hive.openBox("USERBOX");
      final userMap = userBox.get("userData");
      if (userMap != null) {
        userMap['userDisplayName'] = nameController.text;
        userBox.put('userData', userMap);
      }

      ref
          .read(userProvider.notifier)
          .update((state) => state!.copyWith(name: nameController.text));

      KSnackbar(context, content: "Name Updated");
      isLoading.value = false;
    } else {
      isLoading.value = false;
      KSnackbar(context, content: 'Please fill all the Fields', isDanger: true);
    }
  }

  //------------------------->
  final isLoading = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Account', style: TextStyle(fontSize: 25)),
                  Text("v$kAppVersion", style: TextStyle()),
                ],
              ),
              height20,
              Hero(
                tag: 'profImg',
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user!.imgUrl),
                ),
              ),
              height10,
              Row(
                children: [
                  Icon(Icons.tag, color: context.fadeTextColor),
                  width5,
                  Flexible(
                    child: Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 20,
                        color: context.fadeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: nameController,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
                cursorWidth: 1,
                cursorColor: context.colorScheme.onSurface,
                decoration: InputDecoration(
                  focusColor: context.primaryColor,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: context.primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: context.isDarkMode
                          ? Colors.white24
                          : Colors.black12,
                    ),
                  ),
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    fontSize: 25,
                    color: context.fadeTextColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              height10,
              TextField(
                controller: emailController,
                enabled: false,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                cursorWidth: 1,
                cursorColor: context.colorScheme.onSurface,
                decoration: InputDecoration(
                  focusColor: context.primaryColor,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: context.primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: context.isDarkMode
                          ? Colors.white12
                          : Colors.black12,
                    ),
                  ),
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: context.fadeTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              height20,
              kLabel("System Theme"),
              Row(
                children: [
                  _themeBtn("Light"),
                  width10,
                  _themeBtn("Dark"),
                  width10,
                  _themeBtn("System"),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MaterialButton(
            onPressed: () {
              updateAccountDetails(user.uid);
            },
            shape: RoundedRectangleBorder(borderRadius: kRadius(12)),
            elevation: 0,
            padding: EdgeInsets.zero,
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              decoration: BoxDecoration(
                borderRadius: kRadius(12),
                color: context.primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    color: context.isDarkMode ? Colors.black : Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Update',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.isDarkMode ? Colors.black : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeBtn(String theme) {
    return Expanded(
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(themeProvider);
          final notifier = ref.read(themeProvider.notifier);
          final bool isActive = notifier.themeString == theme;

          Color inactiveColor = context.isDarkMode ? Dark.card : Light.card;
          Color inactiveBorderColor = context.isDarkMode
              ? Colors.white12
              : Colors.black12;
          Color activeColor = context.primaryColor.withAlpha(
            context.isDarkMode ? 40 : 30,
          );
          Color activeBorderColor = context.primaryColor;

          return MaterialButton(
            onPressed: () {
              notifier.setTheme(theme);
            },
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(12),
              side: BorderSide(
                color: isActive ? activeBorderColor : inactiveBorderColor,
                width: isActive ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            color: isActive ? activeColor : inactiveColor,
            child: Text(
              theme,
              style: TextStyle(
                color: isActive ? activeBorderColor : context.fadeTextColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
