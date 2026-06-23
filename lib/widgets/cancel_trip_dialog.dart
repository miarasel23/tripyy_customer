import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/localization/app_localization.dart';

class CancelTripDialog extends StatefulWidget {
  final bool isDark;

  const CancelTripDialog({super.key, required this.isDark});

  @override
  State<CancelTripDialog> createState() => _CancelTripDialogState();
}

class _CancelTripDialogState extends State<CancelTripDialog> {
  String _selectedReason = "Waiting for a long time";
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> reasons = [
      AppLocalizations.of(context).translate("waiting_long_time") ?? "Waiting for a long time",
      AppLocalizations.of(context).translate("driver_asked_cancel") ?? "Driver asked to cancel",
      AppLocalizations.of(context).translate("changed_mind") ?? "Changed my mind",
      AppLocalizations.of(context).translate("others") ?? "Others"
    ];

    if (!reasons.contains(_selectedReason)) {
      _selectedReason = reasons.first;
    }

    return Dialog(
      backgroundColor: widget.isDark ? const Color(0xFF1C1E26) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate("why_cancel") ?? "Why are you cancelling?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...reasons.map((reason) {
              return Theme(
                data: ThemeData(
                  unselectedWidgetColor: widget.isDark ? Colors.white54 : Colors.black54,
                ),
                child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    reason,
                    style: GoogleFonts.poppins(
                      color: widget.isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  value: reason,
                  groupValue: _selectedReason,
                  activeColor: const Color(0xFF6C63FF),
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value!;
                    });
                  },
                ),
              );
            }).toList(),
            if (_selectedReason == (AppLocalizations.of(context).translate("others") ?? "Others")) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _otherReasonController,
                maxLines: 3,
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate("write_reason") ?? "Please write your reason...",
                  hintStyle: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black38),
                  filled: true,
                  fillColor: widget.isDark ? const Color(0xFF252833) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: widget.isDark ? Colors.white24 : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context).translate("dismiss") ?? "Dismiss",
                      style: GoogleFonts.poppins(
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      String finalReason = _selectedReason == (AppLocalizations.of(context).translate("others") ?? "Others") 
                          ? _otherReasonController.text.trim() 
                          : _selectedReason;
                      if (_selectedReason == (AppLocalizations.of(context).translate("others") ?? "Others") && finalReason.isEmpty) {
                        return;
                      }
                      Navigator.of(context).pop(finalReason);
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("submit") ?? "Submit",
                      style: GoogleFonts.poppins(
                        color: widget.isDark ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
