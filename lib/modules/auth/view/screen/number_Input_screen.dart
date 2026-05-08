import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/colors_code.dart';
import '../../../localization/Controller/localization_controller.dart';

class NumberInputScreen extends StatelessWidget {
  NumberInputScreen({super.key});

  final TextEditingController numberField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, localizationState) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate("enter_your_phone_number"),
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  numberBasedLoginField(loc, numberField),
                  const SizedBox(height: 10),
                  localizationState.locale.languageCode == "en"
                      ? richTextEnglish(loc)
                      : richTextBangle(loc),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.submitButton,
                      foregroundColor: AppColors.submitButtonText,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.otp,
                        arguments: numberField.text,
                      );
                    },
                    child: Text(
                      loc.translate("continue"),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.submitButtonText, // ✅ correct
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.submitButtonText,
                          backgroundColor: AppColors.submitButton,
                        ),
                        onPressed: () {
                          context.read<LocalizationBloc>().add(
                            ChangeLanguageEvent('en'),
                          );
                        },
                        child: Text(loc.translate("english")),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.submitButtonText,
                          backgroundColor: AppColors.submitButton,
                        ),
                        onPressed: () {
                          context.read<LocalizationBloc>().add(
                            ChangeLanguageEvent('bn'),
                          );
                        },
                        child: Text(loc.translate("bengal")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget richTextEnglish(AppLocalizations loc) {
    return RichText(
      text: TextSpan(
        text: "By proceeding, you consent to agree with our ",
        style: const TextStyle(fontSize: 14, color: Color(0xffb3b3b3)),
        children: [
          TextSpan(
            text: "Terms and Conditions",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget richTextBangle(AppLocalizations loc) {
    return RichText(
      text: TextSpan(
        text: "এগিয়ে যাওয়ার মাধ্যমে, আপনি আমাদের ",
        style: const TextStyle(fontSize: 13, color: Color(0xffb3b3b3)),
        children: [
          TextSpan(
            text: "শর্তাবলী ও নিয়মাবলীর ",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: "সাথে সম্মত হতে রাজি হচ্ছেন।",
            style: const TextStyle(fontSize: 16, color: Color(0xffb3b3b3)),
          ),
        ],
      ),
    );
  }

  Column numberBasedLoginField(
    AppLocalizations loc,
    TextEditingController controller,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xffedf6ff),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.phone, size: 25),
                        const SizedBox(width: 16),
                        Text(
                          loc.translate("+880"),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: loc.translate("enter_your_number"),
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hintText.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
