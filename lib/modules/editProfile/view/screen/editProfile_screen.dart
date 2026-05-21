import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';

class EditprofileScreen extends StatefulWidget {
  const EditprofileScreen({super.key});

  @override
  State<EditprofileScreen> createState() => _EditprofileScreenState();
}

class _EditprofileScreenState extends State<EditprofileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    _name.text = loc.translate("user_name");
    _phoneNumber.text = loc.translate("user_phone_number");
    return Scaffold(
      backgroundColor: AppColors.editProfileScreenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.editProfileScreenAppBarBackground,
        title: Text(
          loc.translate("Profile"),
          style: GoogleFonts.poppins(
            color: AppColors.editProfileScreenProfileText,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.editProfileScreenBackgroundContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: double.infinity,
                  height: 65,
                ),
                Positioned(
                  top: 28,
                  left: 133,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Colors.white),
                      color: AppColors.editProfileScreenProfileIconContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.editProfileScreenProfileIcon,
                      size: 35,
                    ),
                  ),
                ),
                Positioned(
                  top: 53,
                  // left: 146,
                  right: 128,
                  child: Container(
                    padding: EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.editProfileScreenEditButtonContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            AppColors.editProfileScreenEditButtonContainerSide,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Icon(
                        Icons.edit,
                        color: AppColors.editProfileScreenEditButtonIcon,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 38),
            Text(
              loc.translate("name"),
              style: GoogleFonts.poppins(
                color: AppColors.editProfileScreenNameText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.editProfileScreenNameTextfield,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              loc.translate("phone_number"),
              style: GoogleFonts.poppins(
                color: AppColors.editProfileScreenPhoneText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneNumber,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.editProfileScreenPhoneTextfield,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              loc.translate("gender"),
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.editProfileScreenMaleCheckboxContainer,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(width: 1),
                        value: true,
                        onChanged: (value) {},
                      ),
                      Text(loc.translate("male")),
                    ],
                  ),
                ),
                Container(
                  width: 140,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.editProfileScreenFemaleCheckboxContainer,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(width: 1),
                        value: false,
                        onChanged: (value) {},
                      ),
                      Text(loc.translate("female")),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors
                          .editProfileScreenDeleteButtonElevatedbuttonBackground,
                    ),
                    onPressed: () {},
                    child: Text(
                      loc.translate("delete_account"),
                      style: GoogleFonts.poppins(
                        color: AppColors
                            .editProfileScreenDeleteButtonElevatedbuttonForeground,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors
                          .editProfileScreenUpdateButtonElevatedbuttonBackground,
                    ),
                    onPressed: () {},
                    child: Text(
                      loc.translate("update"),
                      style: GoogleFonts.poppins(
                        color: AppColors
                            .editProfileScreenUpdateButtonElevatedbuttonForeground,
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
