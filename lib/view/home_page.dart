import 'package:flutter/material.dart';
import '../controller/localization_controller.dart';
import '../core/localization/app_localization.dart';

class HomePage extends StatelessWidget {
  final LocalizationController controller;

  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate("app_name"))),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text(loc.translate("hello"))),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              controller.changeLanguage('en');
            },
            child: const Text("English"),
          ),

          ElevatedButton(
            onPressed: () {
              controller.changeLanguage('bn');
            },
            child: const Text("বাংলা"),
          ),
        ],
      ),
    );
  }
}
