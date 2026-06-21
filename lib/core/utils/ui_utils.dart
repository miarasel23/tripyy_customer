import 'package:flutter/material.dart';
import 'localization/app_localization.dart';

class UiUtils {
  /// Displays an API error message in a standardized popup dialog
  static void showApiErrorPopup(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(loc.translate("message") ?? "Message"),
          content: Text(errorMessage.replaceAll('Exception: ', '').replaceAll('Error: ', '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
