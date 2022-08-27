import 'package:flutter/material.dart';

class SettingsUi extends StatefulWidget {
  final String tag;
  final String img;
  SettingsUi({
    required this.tag,
    required this.img,
  });

  @override
  _SettingsUiState createState() => _SettingsUiState();
}

class _SettingsUiState extends State<SettingsUi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        widget.img,
                        fit: BoxFit.cover,
                        height: 150,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    "Delete Account",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
