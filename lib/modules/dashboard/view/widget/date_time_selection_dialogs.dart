import 'package:flutter/material.dart';

class DateTimeSelectionDialogs {
  /// Prompts the user to pick a date and then a time.
  static Future<DateTime?> pickDateAndTime(BuildContext context, {DateTime? initialDate}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        return DateTime(date.year, date.month, date.day, time.hour, time.minute);
      }
    }
    return null;
  }

  /// Prompts the user to select hours from 1 to 24 using a simple dropdown/dialog.
  static Future<int?> pickHours(BuildContext context) async {
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Hours"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 24,
              itemBuilder: (context, index) {
                final int hours = index + 1;
                return ListTile(
                  title: Text("$hours ${hours == 1 ? 'Hour' : 'Hours'}"),
                  onTap: () {
                    Navigator.of(context).pop(hours);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
