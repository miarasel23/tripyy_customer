import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/localization/app_localization.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/enums.dart';
import '../../localization/Controller/localization_controller.dart';
import '../controller/send_otp_bloc.dart';
import '../controller/send_otp_event.dart';
import '../controller/send_otp_state.dart';
import '../../../core/utils/ui_utils.dart';

class NumberInputScreen extends StatefulWidget {
  const NumberInputScreen({super.key});

  @override
  State<NumberInputScreen> createState() => _NumberInputScreenState();
}

class _NumberInputScreenState extends State<NumberInputScreen> {
  final TextEditingController numberField = TextEditingController();
  late TapGestureRecognizer _termsGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _termsGestureRecognizer = TapGestureRecognizer()..onTap = _openTermsAndConditions;
    numberField.addListener(_onNumberChanged);
  }

  @override
  void dispose() {
    numberField.removeListener(_onNumberChanged);
    numberField.dispose();
    _termsGestureRecognizer.dispose();
    super.dispose();
  }

  void _onNumberChanged() {
    setState(() {});
  }

  void _openTermsAndConditions() {
    Navigator.pushNamed(
      context,
      AppRoutes.legalPolicy,
      arguments: 'TERMS_CONDITION',
    );
  }

  String? _getValidationError(bool isBn) {
    final text = numberField.text.trim();
    if (text.isEmpty) {
      return null;
    }
    if (text.length < 11) {
      return isBn
          ? "ফোন নম্বরটি অবশ্যই ১১ ডিজিটের হতে হবে"
          : "Phone number must be exactly 11 digits";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, localizationState) {
        final isBn = localizationState.locale.languageCode == "bn";
        final validationError = _getValidationError(isBn);
        final bool isValid = numberField.text.trim().length == 11;

        return BlocListener<SendOtpBloc, SendOtpState>(
          listener: (context, state) {
            if (state.status == OtpStatus.failure) {
              UiUtils.showApiErrorPopup(context, state.errorMessage ?? "Something went wrong");
            }
            if (state.status == OtpStatus.success) {
              Navigator.pushNamed(
                context,
                AppRoutes.otp,
                arguments: numberField.text,
              );
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                _buildLanguageSwitcher(context, loc, localizationState.locale.languageCode),
                const SizedBox(width: 8),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    localizationState.locale.languageCode == "en"
                        ? richTextEnglish(loc)
                        : richTextBangle(loc),
                    const SizedBox(height: 16),
                    BlocBuilder<SendOtpBloc, SendOtpState>(
                      builder: (context, state) {
                        final isBtnEnabled = isValid && state.status != OtpStatus.loading;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBtnEnabled
                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                                : Colors.grey.shade400,
                            foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isBtnEnabled
                              ? () {
                                  context.read<SendOtpBloc>().add(
                                    SendOtp(
                                      numberField.text,
                                      localizationState.locale.languageCode,
                                    ),
                                  );
                                }
                              : null,
                          child: switch (state.status) {
                            OtpStatus.loading => SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            OtpStatus.failure => Text(
                                loc.translate("retry"),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            _ => Text(
                                loc.translate("continue"),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate("enter_your_phone_number"),
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isBn ? "আমরা আপনাকে একটি যাচাইকরণ কোড পাঠাব" : "We will send you a verification code",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? "মোবাইল নম্বর" : "Mobile Number",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          numberBasedLoginField(loc, numberField, validationError),
                          if (validationError != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  validationError,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context, AppLocalizations loc, String currentLang) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton(context, 'en', loc.translate("english"), currentLang == 'en'),
          _langButton(context, 'bn', loc.translate("bengal"), currentLang == 'bn'),
        ],
      ),
    );
  }

  Widget _langButton(BuildContext context, String code, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<LocalizationBloc>().add(ChangeLanguageEvent(code));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget richTextEnglish(AppLocalizations loc) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "By proceeding, you consent to agree with our\n",
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        children: [
          TextSpan(
            text: "Terms and Conditions",
            recognizer: _termsGestureRecognizer,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget richTextBangle(AppLocalizations loc) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "এগিয়ে যাওয়ার মাধ্যমে, আপনি আমাদের\n",
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        children: [
          TextSpan(
            text: "শর্তাবলী ও নিয়মাবলীর ",
            recognizer: _termsGestureRecognizer,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(
            text: "সাথে সম্মত হতে রাজি হচ্ছেন।",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget numberBasedLoginField(AppLocalizations loc, TextEditingController controller, String? error) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(16),
        border: error != null
            ? Border.all(color: Colors.red.shade400, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Text(
            "🇧🇩",
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 8),
          Text(
            "+88",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: loc.translate("enter_your_number"),
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
