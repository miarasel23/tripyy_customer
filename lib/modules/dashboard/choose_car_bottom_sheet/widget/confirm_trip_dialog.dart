import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../model/choose_car_model.dart';

class ConfirmTripDialog extends StatefulWidget {
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
  State<ConfirmTripDialog> createState() => _ConfirmTripDialogState();
}

class _ConfirmTripDialogState extends State<ConfirmTripDialog> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showCustomPriceInput = false;
  int? _selectedQuickPrice;

  @override
  void initState() {
    super.initState();
    final initialPrice = (widget.selectedCar.minimumBookingPrice ?? 0).toInt();
    _selectedQuickPrice = initialPrice > 0 ? initialPrice : null;
    _offerPriceController.text = initialPrice > 0 ? initialPrice.toString() : '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    _offerPriceController.dispose();
    super.dispose();
  }

  bool _isValidOfferPrice() {
    final valStr = _offerPriceController.text.trim();
    if (valStr.isEmpty) return false;
    final num? offerPrice = num.tryParse(valStr);
    if (offerPrice == null) return false;

    final num estFare = widget.selectedCar.minimumBookingPrice ?? 0;
    if (estFare <= 0) return true;

    final num minAllowed = (estFare * 0.90).round();
    final num maxAllowed = (estFare * 1.50).round();

    return offerPrice >= minAllowed && offerPrice <= maxAllowed;
  }

  List<int> _getQuickPrices() {
    final base = (widget.selectedCar.minimumBookingPrice ?? 0).toInt();
    if (base <= 0) return [300, 350, 400];

    int opt1 = base;
    int opt2 = (base * 1.10).round();
    int opt3 = (base * 1.20).round();

    if (opt2 <= opt1) opt2 = opt1 + 30;
    if (opt3 <= opt2) opt3 = opt2 + 30;

    return [opt1, opt2, opt3];
  }

  void _selectPrice(int price) {
    setState(() {
      _selectedQuickPrice = price;
      _offerPriceController.text = price.toString();
    });
  }

  void _submitOffer() {
    if (!_isValidOfferPrice()) return;

    final offerStr = _offerPriceController.text.trim();
    final finalOffer = offerStr.isNotEmpty 
        ? offerStr 
        : (widget.selectedCar.minimumBookingPrice ?? 0).toString();

    Navigator.pop(context, {
      'note': _noteController.text.trim(),
      'offerAmount': finalOffer,
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = loc.locale.languageCode == 'bn';

    final bgColor = isDark ? const Color(0xFF1E1E26) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardBgColor = isDark ? const Color(0xFF2B2B36) : const Color(0xFFF7F8FA);
    final closeBtnBg = isDark ? const Color(0xFF2B2B36) : const Color(0xFFEEF0F4);

    final currentOfferPrice = _offerPriceController.text.trim();
    final displayAmount = currentOfferPrice.isNotEmpty 
        ? currentOfferPrice 
        : (widget.selectedCar.minimumBookingPrice?.toInt() ?? 0).toString();

    final quickPrices = _getQuickPrices();
    final bool isOfferValid = _isValidOfferPrice();
    final bool hasInput = currentOfferPrice.isNotEmpty;
    final bool isInputInvalid = hasInput && !isOfferValid;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Distance (if available)
                if (widget.selectedCar.distance != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      '${widget.selectedCar.distance} km',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 6),

                // Pickup & Drop-off Route Section (Matches Photo 2)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Pickups (A)
                      for (int i = 0; i < widget.pickupAddresses.length; i++) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  widget.pickupAddresses.length > 1 ? '${i + 1}' : 'A',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.pickupAddresses[i],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (i < widget.pickupAddresses.length - 1 || widget.dropoffAddresses.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 2,
                                height: 16,
                                color: isDark ? Colors.white24 : Colors.grey[300],
                              ),
                            ),
                          ),
                      ],

                      // Dropoffs (B)
                      for (int i = 0; i < widget.dropoffAddresses.length; i++) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  widget.dropoffAddresses.length > 1 ? '${i + 1}' : 'B',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.dropoffAddresses[i],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (i < widget.dropoffAddresses.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 2,
                                height: 16,
                                color: isDark ? Colors.white24 : Colors.grey[300],
                              ),
                            ),
                          ),
                      ],

                      const SizedBox(height: 12),
                      Divider(color: isDark ? Colors.white12 : Colors.grey[300], height: 1),
                      const SizedBox(height: 12),

                      // Trip Details: Service, Vehicle, Payment
                      _buildDetailRow(loc.translate("service"), widget.serviceName.replaceAll('_', ' '), subTextColor, textColor),
                      const SizedBox(height: 8),
                      _buildDetailRow(loc.translate("vehicle"), "${widget.selectedCar.carType} (${widget.selectedCar.setCapacity})", subTextColor, textColor),
                      const SizedBox(height: 8),
                      _buildDetailRow(loc.translate("payment"), "CASH", subTextColor, textColor),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main Primary Action Button: Enabled ONLY when offer price meets condition
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOfferValid 
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.grey[800] : Colors.grey[300]),
                      foregroundColor: isOfferValid 
                          ? (isDark ? Colors.black : Colors.white)
                          : Colors.grey[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isOfferValid ? _submitOffer : null,
                    child: Text(
                      isBn 
                          ? 'অফার দিন ৳$displayAmount'
                          : 'Give Offer for BDT $displayAmount',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // "Offer your fare" Section Header
                Center(
                  child: Text(
                    loc.translate("offer_your_fare"),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Quick Fare Chips Row
                Row(
                  children: [
                    for (int price in quickPrices) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectPrice(price),
                          child: Container(
                            height: 48,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black : Colors.black,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _selectedQuickPrice == price 
                                    ? Colors.blue 
                                    : Colors.transparent,
                                width: _selectedQuickPrice == price ? 2 : 0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isBn ? '৳$price' : 'BDT $price',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Custom Edit Button (Pencil Icon)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showCustomPriceInput = !_showCustomPriceInput;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black : Colors.black,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _showCustomPriceInput ? Colors.blue : Colors.transparent,
                            width: _showCustomPriceInput ? 2 : 0,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                // Custom Offer Price Field (Turns Red when invalid, BID NOW button enables when condition met)
                if (_showCustomPriceInput) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _offerPriceController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(
                            color: isInputInvalid ? Colors.red : textColor, 
                            fontSize: 15, 
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            setState(() {
                              _selectedQuickPrice = parsed;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Offer Amount",
                            labelStyle: GoogleFonts.poppins(
                              color: isInputInvalid ? Colors.red : subTextColor, 
                              fontSize: 12,
                            ),
                            prefixText: isBn ? "৳ " : "BDT ",
                            prefixStyle: GoogleFonts.poppins(
                              color: isInputInvalid ? Colors.red : textColor, 
                              fontSize: 15, 
                              fontWeight: FontWeight.w600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: isInputInvalid 
                                  ? const BorderSide(color: Colors.red, width: 2) 
                                  : BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: isInputInvalid 
                                  ? const BorderSide(color: Colors.red, width: 2) 
                                  : BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: isInputInvalid 
                                  ? const BorderSide(color: Colors.red, width: 2) 
                                  : const BorderSide(color: Colors.blue, width: 2),
                            ),
                            filled: true,
                            fillColor: isInputInvalid 
                                ? (isDark ? const Color(0xFF3E1E22) : const Color(0xFFFFEBEE))
                                : (isDark ? const Color(0xFF2B2B36) : const Color(0xFFEEEEEE)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOfferValid 
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark ? Colors.grey[800] : Colors.grey[300]),
                            foregroundColor: isOfferValid 
                                ? (isDark ? Colors.black : Colors.white)
                                : Colors.grey[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            elevation: 0,
                          ),
                          onPressed: isOfferValid ? _submitOffer : null,
                          child: Text(
                            isBn ? "বিড করুন" : "BID NOW",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((widget.selectedCar.minimumBookingPrice ?? 0) > 0) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        isBn 
                            ? 'সর্বনিম্ন: ৳${((widget.selectedCar.minimumBookingPrice! * 0.90).round())}  •  সর্বোচ্চ: ৳${((widget.selectedCar.minimumBookingPrice! * 1.50).round())}'
                            : 'Min: BDT ${((widget.selectedCar.minimumBookingPrice! * 0.90).round())}  •  Max: BDT ${((widget.selectedCar.minimumBookingPrice! * 1.50).round())}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isInputInvalid 
                              ? Colors.red 
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 12),

                // Note Field (Optional)
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  style: GoogleFonts.poppins(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: loc.translate("note"),
                    labelStyle: GoogleFonts.poppins(color: subTextColor, fontSize: 13),
                    hintText: loc.translate("add_note"),
                    hintStyle: GoogleFonts.poppins(color: subTextColor?.withValues(alpha: 0.5), fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2B2B36) : Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Close Button (Matches Photo 2)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: closeBtnBg,
                      foregroundColor: textColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, null),
                    child: Text(
                      loc.translate("close"),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color? labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: labelColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
