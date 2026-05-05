import 'package:flutter/material.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../localization/Controller/localization_controller.dart';

class NumberInputScreen extends StatelessWidget {
  NumberInputScreen({super.key});

  final LocalizationController controller = LocalizationController();
  final TextEditingController numberField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Enter Number")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: numberField,
              decoration: InputDecoration(
                hintText: loc.translate("enter_your_number"),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.otp,
                  arguments: numberField.text,
                );
              },
              child: const Text("Continue"),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () => controller.changeLanguage('en'),
                  child: const Text("English"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => controller.changeLanguage('bn'),
                  child: const Text("বাংলা"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
