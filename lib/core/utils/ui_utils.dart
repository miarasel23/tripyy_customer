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

  /// Shows a theme-aware snackbar:
  ///  - Dark mode  → black background, white text
  ///  - Light mode → white background, black text
  ///
  /// [type] can be 'error', 'success', or 'info' (default).
  /// Error/success types add a small coloured left-side indicator while
  /// keeping the main background theme-aware (black/white).
  static void showAppSnackBar(
    BuildContext context,
    String message, {
    String type = 'info', // 'info' | 'success' | 'error'
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    Color indicatorColor;
    switch (type) {
      case 'success':
        indicatorColor = Colors.green;
        break;
      case 'error':
        indicatorColor = Colors.red;
        break;
      default:
        indicatorColor = isDark ? Colors.white54 : Colors.black38;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
