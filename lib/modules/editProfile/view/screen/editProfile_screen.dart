import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trippy_customer/modules/editProfile/controller/edit_profile_state.dart';
import 'package:trippy_customer/utils/enums.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';
import '../../controller/edit_profile_bloc.dart';
import '../../controller/edit_profile_event.dart';

class EditprofileScreen extends StatefulWidget {
  const EditprofileScreen({super.key});

  @override
  State<EditprofileScreen> createState() => _EditprofileScreenState();
}

class _EditprofileScreenState extends State<EditprofileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(AppLocalizations loc) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      context.read<EditProfilePictureBloc>().add(
        EditProfilePicture(
          imageFile: File(image.path),
          languageCode: loc.locale.languageCode,
          actionWhen: 'admin_login',
          email: 'superadmin@gmail.com',
          password: '123456',
          platform: 'web',
        ),
      );
    }
  }

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
                  child:
                      BlocBuilder<
                        EditProfilePictureBloc,
                        EditProfilePictureState
                      >(
                        builder: (context, state) {
                          if (state.status ==
                              EditProfilePictureStatus.success) {
                            return ClipOval(
                              child: Image.file(
                                state.avatar!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          if (state.status ==
                              EditProfilePictureStatus.loading) {
                            return Container(
                              padding: EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.white,
                                ),
                                color: AppColors
                                    .editProfileScreenProfileIconContainer,
                                shape: BoxShape.circle,
                              ),
                              child: CircularProgressIndicator(
                                color: AppColors
                                    .editProfileScreenCircularProgressIndicator,
                              ),
                            );
                          }
                          return GestureDetector(
                            onTap: () {
                              _pickImage(loc);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.white,
                                ),
                                color: AppColors
                                    .editProfileScreenProfileIconContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: AppColors.editProfileScreenProfileIcon,
                                size: 35,
                              ),
                            ),
                          );
                        },
                      ),
                ),
                Positioned(
                  top: 53,
                  // left: 146,
                  right: 128,
                  child: GestureDetector(
                    onTap: () {
                      _pickImage(loc);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.editProfileScreenEditButtonContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors
                              .editProfileScreenEditButtonContainerSide,
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

  @override
  void dispose() {
    _name.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }
}
