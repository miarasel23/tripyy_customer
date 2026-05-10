import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/colors_code.dart';
import '../../../localization/Controller/localization_controller.dart';

class OtpSignIn extends StatelessWidget {
  final String number;

  const OtpSignIn({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final TextEditingController otpField = TextEditingController();

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, localizationState) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 13.0, top: 5),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate("enter_the_otp_sent_to_you_at"),
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        number,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      otpBasedField(context, otpField),
                      const SizedBox(height: 10),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          loc.translate("change_number"),
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                          Navigator.pushNamed(context, AppRoutes.bottomNav);
                        },
                        child: Text(
                          loc.translate("continue"),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.submitButtonText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: loc.translate("resend_code_in"),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xffb3b3b3),
                            ),
                            children: [
                              TextSpan(
                                text: " 02:00",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.resendCodeTime,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Column otpBasedField(BuildContext context, TextEditingController controller) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xffedf6ff),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: MaterialPinField(
                  length: 6,
                  onCompleted: (pin) => print('PIN: $pin'),
                  onChanged: (value) => print('Changed: $value'),
                  theme: MaterialPinTheme(
                    shape: MaterialPinShape.outlined,
                    cellSize: Size(46, 64),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
