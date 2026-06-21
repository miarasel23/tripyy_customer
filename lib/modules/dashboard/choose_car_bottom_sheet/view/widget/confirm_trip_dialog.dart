import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/localization/app_localization.dart';
import '../../models/choose_car_model.dart';

class ConfirmTripDialog extends StatelessWidget {
  final Car selectedCar;
  final String serviceName;
  final List<String> pickupAddresses;
  final List<String> dropoffAddresses;

  const ConfirmTripDialog({
    super.key,
    required this.selectedCar,
    required this.serviceName,
    required this.pickupAddresses,
    required this.dropoffAddresses,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use a very dark charcoal color like the photo if in dark mode
    final bgColor = isDark ? const Color(0xFF2B2B36) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark ? const Color(0xFF3F3F4E) : Colors.grey[300];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: bgColor,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                loc.translate("confirm_trip") ?? "Trip Summary",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Pickup & Drop-off Header
            Text(
              loc.translate("pickup_and_dropoff") ?? "PICKUP & DROP-OFF",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 12),
            
            // Route Visual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E26) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor ?? Colors.grey),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < pickupAddresses.length; i++)
                    _buildSummaryRow(
                      pickupAddresses.length > 1 ? "Pickup ${i + 1}" : "Pickup", 
                      pickupAddresses[i], 
                      Icons.my_location, 
                      isDark,
                      textColor,
                      subTextColor
                    ),
                  
                  const SizedBox(height: 12),
                  
                  for (int i = 0; i < dropoffAddresses.length; i++)
                    _buildSummaryRow(
                      dropoffAddresses.length > 1 ? "Dropoff ${i + 1}" : "Dropoff", 
                      dropoffAddresses[i], 
                      Icons.location_on, 
                      isDark,
                      textColor,
                      subTextColor
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Divider(color: borderColor),
            const SizedBox(height: 16),
            
            // Trip Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.translate("service") ?? "Service", style: GoogleFonts.poppins(fontSize: 14, color: subTextColor)),
                Text(serviceName.replaceAll('_', ' '), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.translate("vehicle") ?? "Vehicle", style: GoogleFonts.poppins(fontSize: 14, color: subTextColor)),
                Text("${selectedCar.carType} (${selectedCar.setCapacity})", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.translate("payment") ?? "Payment", style: GoogleFonts.poppins(fontSize: 14, color: subTextColor)),
                Text("CASH", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Fare
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E26) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor ?? Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate("estimated_fare") ?? "Estimated Fare", 
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)
                  ),
                  Text(
                    loc.locale.languageCode == 'bn' 
                        ? '৳${selectedCar.minimumBookingPrice}' 
                        : 'BDT ${selectedCar.minimumBookingPrice}',
                     style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)  
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: isDark ? Colors.white : Colors.black),
                      foregroundColor: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(loc.translate("cancel") ?? "Cancel", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(loc.translate("submit") ?? "Submit", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String address, IconData icon, bool isDark, Color textColor, Color? subTextColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: subTextColor, fontWeight: FontWeight.w600)),
              Text(address, style: GoogleFonts.poppins(fontSize: 14, color: textColor, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
